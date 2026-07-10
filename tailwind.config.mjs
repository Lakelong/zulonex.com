import typography from "@tailwindcss/typography";

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        ink: "#06124a",
        muted: "#5d6475",
        line: "#dce8f6",
        mist: "#f2f7fd",
        sea: "#1f61ff",
        ocean: "#4284f4",
        leaf: "#90c0f8",
        amber: "#ff6a2f"
      },
      boxShadow: {
        soft: "0 18px 60px rgba(18, 54, 58, 0.12)",
        tight: "0 10px 30px rgba(18, 54, 58, 0.10)"
      },
      fontFamily: {
        sans: [
          "Inter",
          "ui-sans-serif",
          "system-ui",
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "sans-serif"
        ]
      }
    }
  },
  plugins: [typography]
};
