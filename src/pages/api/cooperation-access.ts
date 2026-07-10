import type { APIRoute } from "astro";
import { mkdir, appendFile, readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import {
  cooperationAccessCookie,
  cooperationAccessMaxAgeSeconds,
  createCooperationAccessToken,
  isValidPhone,
  maskPhone,
  normalizePhone
} from "@/lib/cooperationAccess";

export const prerender = false;

type AccessPayload = {
  phone?: string;
  source?: string;
};

const logFile = () => process.env.COOPERATION_ACCESS_LOG_FILE || join(process.cwd(), "data", "cooperation-access.jsonl");

function sanitize(value: unknown, max = 200) {
  return String(value ?? "").trim().slice(0, max);
}

function getIp(request: Request, clientAddress?: string) {
  const forwarded = request.headers.get("x-forwarded-for")?.split(",")[0]?.trim();
  return forwarded || clientAddress || "";
}

async function appendAccessLog(entry: Record<string, unknown>) {
  const file = logFile();
  await mkdir(dirname(file), { recursive: true });
  await appendFile(file, `${JSON.stringify(entry)}\n`, "utf8");
}

async function readAccessLogs(limit: number) {
  try {
    const content = await readFile(logFile(), "utf8");
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

export const POST: APIRoute = async ({ request, cookies, clientAddress }) => {
  let raw: AccessPayload;

  try {
    raw = await request.json();
  } catch {
    return Response.json({ message: "提交格式不正确，请刷新后重试。" }, { status: 400 });
  }

  const phone = normalizePhone(raw.phone);
  if (!isValidPhone(phone)) {
    return Response.json({ message: "请填写有效的中国大陆手机号。" }, { status: 400 });
  }

  const token = createCooperationAccessToken(phone);
  const createdAt = new Date().toISOString();
  const userAgent = sanitize(request.headers.get("user-agent"), 500);
  const referer = sanitize(request.headers.get("referer"), 500);

  try {
    await appendAccessLog({
      type: "cooperation_model_access",
      phone,
      maskedPhone: maskPhone(phone),
      source: sanitize(raw.source || "cooperation-latest-model"),
      ip: getIp(request, clientAddress),
      userAgent,
      referer,
      createdAt
    });
  } catch (error) {
    console.error(error);
    return Response.json({ message: "验证暂时失败，请稍后再试。" }, { status: 500 });
  }

  cookies.set(cooperationAccessCookie, token, {
    httpOnly: true,
    maxAge: cooperationAccessMaxAgeSeconds,
    path: "/",
    sameSite: "lax",
    secure: new URL(request.url).protocol === "https:"
  });

  return Response.json({
    ok: true,
    message: "验证通过。",
    redirect: "/projects/xinglu-cooperation-school/"
  });
};

export const GET: APIRoute = async ({ request }) => {
  const adminToken = process.env.COOPERATION_ACCESS_ADMIN_TOKEN;
  if (!adminToken) {
    return Response.json({ message: "后台访问口令尚未配置。" }, { status: 501 });
  }

  const url = new URL(request.url);
  const tokenFromHeader = request.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  const token = tokenFromHeader || url.searchParams.get("token");

  if (token !== adminToken) {
    return Response.json({ message: "无权查看访问历史。" }, { status: 403 });
  }

  const limit = Math.min(Math.max(Number(url.searchParams.get("limit") || 100), 1), 500);
  const logs = await readAccessLogs(limit);

  return Response.json(
    { logs },
    {
      headers: {
        "Cache-Control": "no-store"
      }
    }
  );
};
