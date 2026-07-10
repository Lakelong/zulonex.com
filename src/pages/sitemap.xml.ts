import type { APIRoute } from "astro";

export const prerender = true;

const routes = [
  "",
  "product/",
  "project/",
  "solutions/",
  "cooperation/",
  "faq/",
  "insights/",
  "insights/ai-learning-space-operation/",
  "insights/partner-launch-process/",
  "insights/xinglu-product-overview/",
  "insights/zulonex-company-intro/",
  "about/",
  "contact/",
  "privacy/",
  "terms/"
];

export const GET: APIRoute = ({ site }) => {
  const origin = site ?? new URL("https://zulonex.com");
  const urls = routes
    .map((route) => `<url><loc>${new URL(route, origin).toString()}</loc></url>`)
    .join("");

  return new Response(
    `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls}</urlset>`,
    {
      headers: {
        "Content-Type": "application/xml; charset=utf-8"
      }
    }
  );
};
