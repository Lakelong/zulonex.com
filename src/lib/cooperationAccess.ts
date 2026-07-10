import { createHmac, timingSafeEqual, randomBytes } from "node:crypto";

export const cooperationAccessCookie = "zulonex_cooperation_access";
export const cooperationAccessMaxAgeSeconds = 60 * 60 * 24 * 7;

const phonePattern = /^1[3-9]\d{9}$/;

type AccessPayload = {
  phone: string;
  exp: number;
  nonce: string;
};

function secret() {
  return process.env.COOPERATION_ACCESS_SECRET || "zulonex-local-cooperation-access-secret";
}

function sign(payload: string) {
  return createHmac("sha256", secret()).update(payload).digest("base64url");
}

export function normalizePhone(value: unknown) {
  return String(value ?? "").replace(/\D/g, "").slice(0, 11);
}

export function isValidPhone(phone: string) {
  return phonePattern.test(phone);
}

export function maskPhone(phone: string) {
  if (!isValidPhone(phone)) return "";
  return `${phone.slice(0, 3)}****${phone.slice(7)}`;
}

export function createCooperationAccessToken(phone: string) {
  const payload: AccessPayload = {
    phone,
    exp: Date.now() + cooperationAccessMaxAgeSeconds * 1000,
    nonce: randomBytes(8).toString("hex")
  };
  const encoded = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
  return `${encoded}.${sign(encoded)}`;
}

export function verifyCooperationAccessToken(token: string | undefined) {
  if (!token || !token.includes(".")) return null;

  const [encoded, signature] = token.split(".");
  const expected = sign(encoded);
  const givenBuffer = Buffer.from(signature);
  const expectedBuffer = Buffer.from(expected);

  if (givenBuffer.length !== expectedBuffer.length || !timingSafeEqual(givenBuffer, expectedBuffer)) {
    return null;
  }

  try {
    const payload = JSON.parse(Buffer.from(encoded, "base64url").toString("utf8")) as AccessPayload;
    if (!isValidPhone(payload.phone) || payload.exp < Date.now()) return null;
    return payload;
  } catch {
    return null;
  }
}
