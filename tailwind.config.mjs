import typography from "@tailwindcss/typography";

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        ink: "rgb(var(--z-ink-rgb) / <alpha-value>)",
        muted: "rgb(var(--z-muted-rgb) / <alpha-value>)",
        line: "rgb(var(--z-line-rgb) / <alpha-value>)",
        mist: "rgb(var(--z-mist-rgb) / <alpha-value>)",
        sea: "rgb(var(--z-sea-rgb) / <alpha-value>)",
        ocean: "rgb(var(--z-ocean-rgb) / <alpha-value>)",
        leaf: "rgb(var(--z-leaf-rgb) / <alpha-value>)",
        amber: "rgb(var(--z-amber-rgb) / <alpha-value>)"
      },
      boxShadow: {
        soft: "var(--z-shadow-soft)",
        tight: "var(--z-shadow-tight)"
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
