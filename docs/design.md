# ZULONEX Editorial Design System

当前官网以“蓝白编辑式科技感”为默认主题，页面结构保持内容优先、留白充足、动效克制。所有共享组件应优先使用语义 token，而不是直接写颜色、阴影或圆角值。

## 设计契约

- **主色**：`--z-sea` / `sea`，用于行动、链接、焦点和进度反馈。
- **文字**：`--z-ink` / `ink` 为标题与高对比文字；`--z-muted` / `muted` 为正文与说明。
- **表面**：`--z-bg` 页面底色，`--z-surface` 内容表面，`--z-surface-soft` 轻强调表面。
- **边界**：`--z-line` / `line` 只用于必要的分隔和焦点，不把每个内容块都做成描边卡片。
- **圆角**：`sm 10px`、`md 16px`、`lg 24px`、`xl 32px`。交互控件至少使用 `sm`，内容卡片使用 `lg`。
- **阴影**：统一使用 `shadow-soft` 与 `shadow-tight`，避免组件各自发明阴影。
- **间距**：页面容器使用 `container-page`；章节垂直节奏优先使用 20/28/32/48/64 的倍数。
- **动效**：优先 `data-reveal`、`motion-link` 和 transform/opacity；尊重 `prefers-reduced-motion`。

## 主题

页面根节点使用 `data-theme`：

- `v2`：当前蓝白主题（默认）。
- `classic`：深蓝旧版主题基线，用于回看旧视觉方向。
- `dark`：深色阅读主题基线。

主题可在浏览器控制台快速切换：

```js
window.ZulonexTheme.apply("classic")
window.ZulonexTheme.apply("v2")
window.ZulonexTheme.apply("dark")
```

选择会写入 `localStorage` 的 `zulonex-theme`，刷新后保留。新增页面或组件时只应依赖语义色和 token；不要把主题值硬编码到组件内。

## 图片与团队模块

- 图片统一使用 `object-cover`，人物照片以 4:5 视觉框裁切，`object-position: top` 保留面部与肩部信息。
- 董事长作为独立 spotlight；其余核心团队保持四列桌面网格、两列平板网格、单列移动网格。
- 团队卡片不显示流水序号，姓名、职务、职责形成清晰的信息层级。
- 新增照片必须通过 `src/assets/team` 导入，并在 `about.astro` 的 `teamMembers` 中按姓名明确映射。

## 可访问性与性能

- 所有图片必须有描述性 `alt`；装饰图片使用空 alt。
- 交互控件必须保留键盘焦点样式和可读的 `aria-label`。
- 首屏主视觉优先加载，团队与长页图片懒加载。
- 动画不是信息来源；关闭动效后内容与操作仍完整可用。
