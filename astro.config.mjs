import { defineConfig } from "astro/config";
import node from "@astrojs/node";

export default defineConfig({
  output: "static",
  devToolbar: {
    enabled: false
  },
  adapter: node({
    mode: "standalone"
  }),
  site: "https://zulonex.com"
});
