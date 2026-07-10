# 案例与洞察维护说明

官网“案例与洞察”内容来自 `src/content/insights/` 目录下的 Markdown 文件。

## 新增一篇文章

1. 在 `src/content/insights/` 新建一个 `.md` 文件。
2. 文件名会成为访问地址，例如 `partner-launch-process.md` 对应 `/insights/partner-launch-process/`。
3. 在文件顶部写 frontmatter：

```md
---
title: "文章标题"
date: "2026-07-09"
type: "合作实践"
summary: "一句话摘要，会显示在列表页和 SEO 描述里。"
cover: "/assets/insights/example.webp"
published: true
---
```

`cover` 可选。建议把封面图放在 `public/assets/insights/`，页面里填写 `/assets/insights/文件名.webp`。如果不填，系统会使用默认封面。

## 编辑或下架

- 编辑正文：直接修改对应 `.md` 文件。
- 调整排序：修改 `date`，列表页会按日期倒序排列。
- 临时下架：把 `published` 改成 `false`。
- 修改分类标签：修改 `type`，例如 `产品介绍`、`合作实践`、`运营方法`、`案例分享`。

## 正文格式

正文使用 Markdown：

```md
## 二级标题

段落文字。

- 列表项
- 列表项
```

发布前运行：

```bash
npm run check
npm run build
```
