import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

const insights = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/insights" }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    type: z.string(),
    summary: z.string(),
    cover: z.string().optional(),
    published: z.boolean().default(true)
  })
});

export const collections = { insights };
