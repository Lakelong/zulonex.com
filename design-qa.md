# ZULONEX 新版官网 Design QA

日期：2026-07-16  
项目：`/Users/lake/Documents/zulonex.com-new-visual`  
本地预览：`http://localhost:4323/`

## 视觉真值与实现证据

- source visual truth path：`/var/folders/_3/dl08z_g17jq4h8zpqthftw8w0000gn/T/codex-clipboard-197a1b4f-77ce-4c89-bf27-3b7f8a7b3209.png`
- brand graphic source：`/Users/lake/Downloads/icon/zulo.svg`
- implementation screenshot path：`audit-evidence/2026-07-15/revision-3/product-desktop-cdp.png`
- full-view comparison evidence：`audit-evidence/2026-07-15/revision-3/source-implementation-comparison.png`（左：用户参考图；右：产品页实现）
- mobile evidence：`audit-evidence/2026-07-15/revision-3/product-mobile-cdp.png`
- focused page evidence：`product-capabilities-cdp.png`、`solutions-desktop-cdp.png`、`solutions-scene-cdp.png`、`cooperation-desktop-cdp.png`、`about-desktop-cdp.png`、`contact-desktop-cdp.png`、`home-orbit-cdp.png`
- browser checks：`audit-evidence/2026-07-15/revision-3/browser-checks.json`
- navigation and first-paint evidence：`audit-evidence/2026-07-16/navigation-top-fix/`
- navigation checks：`audit-evidence/2026-07-16/navigation-top-fix/navigation-checks.json`
- design specification：`design.md`

## Viewport 与状态

- 对比主视口：桌面 1440 × 1000；合并比较图按共同可视比例归一到 1440 × 818。
- 响应式视口：移动 390 × 844，真实 CSS viewport，deviceScaleFactor 1。
- 状态：未登录公开官网；Hero 顶部导航深色叠加态；章节滚动后的白色固定导航态；移动菜单展开态。
- 路由：产品、解决方案、合作支持、关于我们、预约演示，以及首页品牌 SVG Banner。

## Findings

- 最终对比未发现可执行的 P0、P1 或 P2 问题。
- 字体与排版：DM Sans Variable + 中文系统字体栈保持参考图的轻中字重、大标题、紧凑行高和高对比层级；移动标题没有裁切、溢出或单字孤行。
- 间距与布局：核心内页已统一为导航叠图、16 px 桌面外间距（移动 8 px）、22 px 图片圆角与左下白色标题缺口；Hero 与后续内容之间有清晰呼吸区。
- 色彩与视觉令牌：白色为主界面，品牌蓝只用于 CTA、眉题、图标和编号；浅蓝、雾紫和天空蓝承担柔色分区；没有旧版深蓝大面积遮罩残留。
- 图片与资产：Hero 均使用亚洲 K12 青少年、导学或真实公司场景；品牌装饰只使用用户提供的 `zulo.svg`，没有手绘 SVG、CSS 曲线或占位图替代。
- 文案与内容：信息架构和业务逻辑保持不变；Hero 文案只做版式重组，单一 H1、CTA 语义和原业务入口保持完整。
- 图标与形状：使用统一线性图标；产品能力编号和图标改为无描边圆形底；卡片默认无描边，仅表单、玻璃浮层、必要分隔与焦点状态保留边界。
- 可访问性与行为：移动菜单可打开且 ARIA 状态同步；焦点轮廓保留；页面无横向溢出；浏览器 Console 无页面脚本错误。

## Focused Region Comparison

主比较图本身就是 2880 × 818 的高分辨率 Hero 并排输入，导航、Logo、玻璃浮层、标题缺口、按钮、图片裁切与圆角均可清晰读取，因此不再重复裁一张更小的 Hero 局部图。另用 `product-capabilities-cdp.png` 和 `solutions-scene-cdp.png` 检查用户批注中的列表左边距、编号样式、卡片描边和场景卡内部圆角。

## Comparison History

### 第 1 轮：内页 Hero 与导航风格漂移

- [P1] 除首页外，内页使用独立白色导航或深色横幅，缺少参考图的导航叠图、外边距和白色标题缺口。
- 修复：新增共享 `EditorialHero`，统一产品、解决方案、合作支持、项目、FAQ、预约演示、洞察页面；关于页视频 Hero 使用同一缺口结构。
- 后续证据：`product-desktop-cdp.png`、`solutions-desktop-cdp.png`、`cooperation-desktop-cdp.png`、`about-desktop-cdp.png`、`contact-desktop-cdp.png`。

### 第 2 轮：卡片描边与产品能力列表

- [P2] 产品能力序号靠边、间距不足，卡片和多个场景模块存在旧式描边。
- 修复：能力列表增加 34 px 桌面内边距、圆形编号和圆形图标底；全局互动卡默认无描边，并清除解决方案内部 inset outline、深色步骤卡边框和方法卡圆形控件描边。
- 后续证据：`product-capabilities-cdp.png`、`solutions-scene-cdp.png`。

### 第 3 轮：品牌 SVG 与移动标题

- [P1] 旧品牌背景图来自完整 Logo 裁切，不是用户本轮提供的线形 SVG。
- 修复：原样引入 `src/assets/brand/zulo.svg`，首页 Orbit 与 CTA 只对该文件做等比放大和局部裁切。
- [P2] 首次 390 px 浏览器检查中，产品 Hero 第二行标题出现单字孤行。
- 修复：标题按语义行输出，移动端使用 37–42 px 响应式字号并保持每一语义行不拆分。
- 后续证据：`home-orbit-cdp.png`、`product-mobile-cdp.png`；390 px 页面 `scrollWidth` 等于 `innerWidth`。

### 第 4 轮：内页导航首帧与 Hero 顶部留白

- [P1] 内页导航在服务端首帧默认以浅色主题输出，脚本运行后才切换为深色叠图态，页面跳转时可能短暂出现白底。
- 修复：根据公开路由在服务端直接输出正确的导航主题，保留滚动采样作为后续状态更新；无 JavaScript 的首帧截图也保持透明深色导航。
- [P1] 共享内页 Hero 只有左右 16 px 留白，顶部图片从 `y=0` 开始，和首页的四周 16 px 容器结构不一致。
- 修复：为全部共享内页 Hero 增加与首页一致的外层白色留白容器；桌面图片边界为上/左/右 16 px，移动端为 8 px；关于页视频 Hero 同步使用该结构。
- 后续证据：`home-desktop.png`、`product-desktop.png`、`solutions-desktop.png`、`about-desktop.png`、`product-mobile.png`、`product-first-paint-no-js.png`。

## Primary Interactions Tested

- 移动菜单按钮：`aria-expanded` 从 `false` 切换为 `true`，菜单可见。
- 导航主题：Hero 顶部为白色 Logo/文字叠图态，滚动至章节后为白色固定导航态。
- 导航首帧：首页、产品、解决方案、合作支持、关于我们、项目、FAQ、预约演示与洞察的服务端 HTML 均直接输出 `data-theme="dark"`，没有由浅到深的主题跳变。
- 锚点入口：产品核心能力、解决方案场景与首页 Orbit 均可直接定位。
- Console errors checked：`browser-checks.json` 中 `errors: []`。
- 横向溢出：390、1440 视口均为 `scrollWidth === innerWidth`。

## Open Questions

- 无。按用户要求，本轮只保留本地预览，不公开发布。

## Implementation Checklist

- [x] 内页 Hero 与首页参考语法统一。
- [x] 解决方案菜单外层透明并使用独立轻浮卡。
- [x] 产品能力列表间距、左边距、编号与图标样式重做。
- [x] 默认卡片与内部模块去除非必要描边。
- [x] 用户提供的 `zulo.svg` 原样接入并延展使用。
- [x] `design.md` 更新到 2.1 规则。
- [x] 390 px / 1440 px 浏览器渲染、移动菜单、Console、类型检查与生产构建通过。
- [x] 首页与全部共享内页 Hero 的顶部/左右留白统一为桌面 16 px、移动 8 px。
- [x] 深色 Hero 页面服务端首帧导航主题正确，无 JavaScript 状态下同样成立。

## Follow-up Polish

- P3：后续如增加新的品牌 Banner，继续从 `zulo.svg` 选择不同局部裁切，避免每页重复同一段线条。

final result: passed
