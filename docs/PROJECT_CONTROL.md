# 项目总控

> 版本：v1.0  
> 更新时间：2026-08-13  
> 当前阶段：M1 本地 Demo  
> 状态：正式架构已确定；M1 演示关键能力，M2 实现生产后端

## 唯一资料入口

- 项目简报：[PROJECT_BRIEF.md](./PROJECT_BRIEF.md)
- 产品架构：[PRODUCT_ARCHITECTURE.md](./PRODUCT_ARCHITECTURE.md)
- M1 PRD：[PRD_M1_DEMO.md](./PRD_M1_DEMO.md)
- M1 实施：[IMPLEMENTATION_PLAN_M1.md](./IMPLEMENTATION_PLAN_M1.md)
- M2 生产方案：[PRODUCTION_DELIVERY_AND_TECHNICAL_PLAN.md](./PRODUCTION_DELIVERY_AND_TECHNICAL_PLAN.md)
- AI Native 标准：[AI_NATIVE_ENGINEERING_STANDARD.md](./AI_NATIVE_ENGINEERING_STANDARD.md)
- 验收矩阵：[ACCEPTANCE_MATRIX.md](./ACCEPTANCE_MATRIX.md)
- 决策日志：[DECISIONS_AND_OPEN_QUESTIONS.md](./DECISIONS_AND_OPEN_QUESTIONS.md)

## 当前结论

- 总部统一建设和运营一套系统，不为代理商复制独立部署。
- 正式数字架构为一个公开官网、一个统一内容协同后台、两种角色权限、一条品牌治理发布链路。
- `/console` 是 M1 统一后台入口；`/console/content/new` 是发布编辑器；`/preview` 仅用于内部全景与演示导航。
- M1 只演示关键产品能力，模拟数据不能被解释为生产系统。
- M2 才建设真实后端、账号/RBAC、数据库、对象存储、AI 接入与测试环境。

## 当前优先级

| 优先级 | 任务 | 状态 | 输出/验收 |
|---|---|---|---|
| P0-1 | 发布编辑器最终还原 | 主线执行中，不停止 | `/console/content/new`；严格遵循 `design.md`；完成基本排版、图片、封面、草稿、预览和送审体验 |
| P0-1 Bug | 侧栏字体视觉问题 | 随 P0-1 修复并自测 | 字号、字重、行高和层级与设计系统一致，无溢出或跳动 |
| P0-2 | M1 四条闭环最终回归与证据 | P0-1 后执行 | 自主创作发布、官方内容复用、退回修改、官网发布后生成渠道包；桌面/移动、双角色证据 |
| P0-3 | M1 资料核验与用户验收 | P0-2 后执行 | 依据验收矩阵核验；用户最终验收 |
| M2 | 生产化方案评审与后端开发 | M1 验收后 | 技术选型、数据/权限模型、安全合规评审通过后才实施 |

## 当前执行边界

- 主线继续完成发布编辑器，不因本轮生产架构资料更新而停止或切换模块。
- 本轮不修改 Demo/代码、不部署、不购买云资源、不解析域名。
- 不通知主线开始 M2 或新模块。
- 正式架构与 M1 当下代码进度分开管理：架构已确定，不代表生产后端已经存在。

## 阶段路线

| 阶段 | 目标 | 阶段闸门 |
|---|---|---|
| M1 | 本地 Demo、全流程演示、体验确认 | 验收矩阵通过且用户确认 |
| M2 | 生产方案、数据模型、账号/RBAC、API、数据库、对象存储、AI 接入、测试环境 | 生产技术方案、安全和合规评审通过后才创建云资源 |
| Beta | 合肥少量真实授权主体、真实内容审核、真实资源、受控线上测试 | 权限、安全、备份、恢复与合规验收通过 |
| 正式试点 | 接入备案/HTTPS/DNS、真实代理商官网空间、运营与指标复盘 | Beta 闸门通过并完成上线核验 |
| 规模化 | 批量开通、标准培训和资源、CRM/分发/官方 API 按需渐进 | 试点指标与运营能力达到扩展门槛 |

## 例行更新格式

每次重要更新记录：任务、状态、输出位置、验证证据、风险/待确认和下一行动。架构、数据模型、权限、合规、安全和部署变化必须先进入决策日志。

## 当前待确认

详见 [PRODUCTION_DELIVERY_AND_TECHNICAL_PLAN.md](./PRODUCTION_DELIVERY_AND_TECHNICAL_PLAN.md#待用户确认的生产化技术选项) 与 [DECISIONS_AND_OPEN_QUESTIONS.md](./DECISIONS_AND_OPEN_QUESTIONS.md)。

