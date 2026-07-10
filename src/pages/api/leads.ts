import type { APIRoute } from "astro";
import { mkdir, appendFile, readFile } from "node:fs/promises";
import { dirname, join } from "node:path";

export const prerender = false;

type LeadPayload = {
  name?: string;
  phone?: string;
  organization?: string;
  city?: string;
  role?: string;
  cooperationType?: string;
  message?: string;
  privacy?: string | boolean;
};

type LeadRecord = Required<Pick<LeadPayload, "name" | "phone" | "organization" | "city" | "role" | "cooperationType" | "message">> & {
  privacy: true;
  source: string;
  ip?: string;
  userAgent?: string;
  referer?: string;
  createdAt: string;
};

const requiredFields: Array<keyof LeadPayload> = [
  "name",
  "phone",
  "organization",
  "city",
  "role",
  "cooperationType",
  "message"
];

const phonePattern = /^1[3-9]\d{9}$/;
const leadsFile = () => process.env.LEADS_FILE || join(process.cwd(), "data", "leads.jsonl");

function sanitize(value: unknown) {
  return String(value ?? "").trim().slice(0, 600);
}

function getIp(request: Request, clientAddress?: string) {
  const forwarded = request.headers.get("x-forwarded-for")?.split(",")[0]?.trim();
  return forwarded || clientAddress || "";
}

function markdown(payload: LeadRecord) {
  return [
    "### 星鹿爱学官网新预约",
    `姓名：${payload.name}`,
    `手机号：${payload.phone}`,
    `机构：${payload.organization}`,
    `城市：${payload.city}`,
    `身份：${payload.role}`,
    `合作类型：${payload.cooperationType}`,
    `需求：${payload.message}`,
    `提交时间：${payload.createdAt}`
  ].join("\n");
}

async function notifyWechat(content: string) {
  const url = process.env.WECHAT_WEBHOOK_URL;
  if (!url) return;

  await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      msgtype: "markdown",
      markdown: { content }
    })
  });
}

async function notifyFeishu(content: string) {
  const url = process.env.FEISHU_WEBHOOK_URL;
  if (!url) return;

  await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      msg_type: "text",
      content: { text: content.replace(/^### /, "") }
    })
  });
}

function feishuField(name: string, fallback: string) {
  return process.env[name] || fallback;
}

async function getFeishuTenantAccessToken() {
  const appId = process.env.FEISHU_APP_ID;
  const appSecret = process.env.FEISHU_APP_SECRET;

  if (!appId || !appSecret) return "";

  const response = await fetch("https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal", {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=utf-8" },
    body: JSON.stringify({
      app_id: appId,
      app_secret: appSecret
    })
  });
  const result = await response.json();

  if (!response.ok || result.code !== 0 || !result.tenant_access_token) {
    throw new Error(result.msg || "获取飞书 tenant_access_token 失败");
  }

  return String(result.tenant_access_token);
}

async function syncFeishuBitable(lead: LeadRecord) {
  const appToken = process.env.FEISHU_BITABLE_APP_TOKEN;
  const tableId = process.env.FEISHU_BITABLE_TABLE_ID;
  if (!appToken || !tableId) return;

  const token = await getFeishuTenantAccessToken();
  if (!token) return;

  const fields = {
    [feishuField("FEISHU_LEADS_FIELD_CREATED_AT", "提交时间")]: lead.createdAt,
    [feishuField("FEISHU_LEADS_FIELD_NAME", "姓名")]: lead.name,
    [feishuField("FEISHU_LEADS_FIELD_PHONE", "手机号")]: lead.phone,
    [feishuField("FEISHU_LEADS_FIELD_ORGANIZATION", "机构名称")]: lead.organization,
    [feishuField("FEISHU_LEADS_FIELD_CITY", "所在城市")]: lead.city,
    [feishuField("FEISHU_LEADS_FIELD_ROLE", "身份角色")]: lead.role,
    [feishuField("FEISHU_LEADS_FIELD_COOPERATION_TYPE", "合作类型")]: lead.cooperationType,
    [feishuField("FEISHU_LEADS_FIELD_MESSAGE", "需求描述")]: lead.message,
    [feishuField("FEISHU_LEADS_FIELD_SOURCE", "来源")]: lead.source,
    [feishuField("FEISHU_LEADS_FIELD_IP", "IP")]: lead.ip || ""
  };

  const response = await fetch(
    `https://open.feishu.cn/open-apis/bitable/v1/apps/${encodeURIComponent(appToken)}/tables/${encodeURIComponent(tableId)}/records`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json; charset=utf-8"
      },
      body: JSON.stringify({ fields })
    }
  );
  const result = await response.json();

  if (!response.ok || result.code !== 0) {
    throw new Error(result.msg || "飞书多维表格写入失败");
  }
}

async function readLeadLogs(limit: number) {
  try {
    const content = await readFile(leadsFile(), "utf8");
    return content
      .split("\n")
      .filter(Boolean)
      .map((line) => JSON.parse(line))
      .slice(-limit)
      .reverse();
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return [];
    throw error;
  }
}

export const POST: APIRoute = async ({ request, clientAddress }) => {
  let raw: LeadPayload;

  try {
    raw = await request.json();
  } catch {
    return Response.json({ message: "提交格式不正确，请刷新后重试。" }, { status: 400 });
  }

  const payload = Object.fromEntries(
    Object.entries(raw).map(([key, value]) => [key, sanitize(value)])
  ) as LeadPayload;

  const missing = requiredFields.find((field) => !payload[field]);
  if (missing) {
    return Response.json({ message: "请完整填写预约信息。" }, { status: 400 });
  }

  if (!phonePattern.test(payload.phone ?? "")) {
    return Response.json({ message: "请填写有效的中国大陆手机号。" }, { status: 400 });
  }

  if (!raw.privacy) {
    return Response.json({ message: "请先确认隐私与沟通授权。" }, { status: 400 });
  }

  const lead = {
    ...payload,
    privacy: true,
    source: "website",
    ip: getIp(request, clientAddress),
    userAgent: sanitize(request.headers.get("user-agent")),
    referer: sanitize(request.headers.get("referer")),
    createdAt: new Date().toISOString()
  } as LeadRecord;

  const content = markdown(lead);
  const file = leadsFile();

  try {
    await mkdir(dirname(file), { recursive: true });
    await appendFile(file, `${JSON.stringify(lead)}\n`, "utf8");
    const results = await Promise.allSettled([
      notifyWechat(content),
      notifyFeishu(content),
      syncFeishuBitable(lead)
    ]);

    results.forEach((result) => {
      if (result.status === "rejected") console.error(result.reason);
    });
  } catch (error) {
    console.error(error);
    return Response.json({ message: "提交暂时失败，请稍后再试。" }, { status: 500 });
  }

  return Response.json({ ok: true, message: "预约已提交。" });
};

export const GET: APIRoute = async ({ request }) => {
  const adminToken = process.env.LEADS_ADMIN_TOKEN;
  if (!adminToken) {
    return Response.json({ message: "线索后台访问口令尚未配置。" }, { status: 501 });
  }

  const url = new URL(request.url);
  const tokenFromHeader = request.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  const token = tokenFromHeader || url.searchParams.get("token");

  if (token !== adminToken) {
    return Response.json({ message: "无权查看预约线索。" }, { status: 403 });
  }

  const limit = Math.min(Math.max(Number(url.searchParams.get("limit") || 100), 1), 500);
  const leads = await readLeadLogs(limit);

  return Response.json(
    { leads },
    {
      headers: {
        "Cache-Control": "no-store"
      }
    }
  );
};
