# AGENTS.md

## Project Role

This repository is the ZULONEX official website project.

Use this project for:

- ZULONEX official website implementation.
- Star Deer Learning / Xinglu Aixue website pages.
- Project landing pages and sales-facing HTML pages.
- Lead forms, SEO, responsive layout, and deployable website builds.

For project-level coordination, read:

- `/Users/longwei/Documents/GitHub/Airething/AI Business OS/项目管理/Project Control Center/config/repositories.json`
- `/Users/longwei/Documents/GitHub/Airething/AI Business OS/项目管理/Project Control Center/docs/GIT_SOURCE_OF_TRUTH.md`

## Tech Stack

- Astro
- Tailwind CSS
- TypeScript
- Node adapter for production server output
- `lucide-static` for icons when available

## Common Commands

Use these commands from the repository root:

```bash
npm run dev
npm run check
npm run build
npm run preview
npm run test
```

Production-style local start:

```bash
PORT=4322 HOST=127.0.0.1 npm run start
```

`npm run test` currently runs `astro check` and `astro build`.

## Working Agreements

- Keep changes scoped to the requested page, component, data file, or style system.
- Preserve user changes already present in the working tree.
- Do not move project directories or rename major folders unless explicitly asked.
- Do not modify release archives or checksum files unless the task is specifically about release packaging.
- Prefer existing Astro components, Tailwind conventions, and project styles before introducing new abstractions.
- For icons, prefer `lucide-static` or the project's existing icon pattern.
- For content claims about products, partners, pricing, team, or capabilities, use provided project sources or flag missing information instead of inventing details.
- Keep user-facing Chinese copy polished, concise, and sales-ready.

## Design And Frontend Standards

- Prioritize production-quality responsive layout on desktop and mobile.
- Avoid text overflow, crowded cards, and incoherent overlaps.
- Match the current ZULONEX visual direction unless the task asks for a redesign.
- Keep operational/product pages clear and scannable rather than overly decorative.
- Use stable dimensions for repeated cards, buttons, grids, and navigation elements.
- Validate important visual changes with a local preview when practical.

## Verification

Before finishing code or content changes, run the narrowest useful checks:

```bash
npm run check
npm run build
```

For larger changes, run:

```bash
npm run test
```

When changing visual pages:

- Start or reuse a local dev/preview server.
- Check desktop and mobile layouts.
- Inspect console errors if a browser is used.
- Report what was verified and what was not.

## Git And Parallel Work

- This is a Git repository. Use branches or Codex worktrees for parallel work.
- Do not overwrite another device's uncommitted changes.
- If the working tree is dirty, identify whether changes are related before editing the same files.
- Keep generated build artifacts out of commits unless the task explicitly needs a deployable package.

## Project Control Updates

When a task changes project direction, creates a new deliverable, or completes a significant milestone, update or propose an update to:

```text
/Users/longwei/Documents/GitHub/Airething/AI Business OS/项目管理/Project Control Center/PROJECT_STATUS.md
```

Record:

- Task name
- Status
- Output location
- Verification performed
- Next action

## Nested Projects

The `geo/` directory appears to be a separate project with its own `package.json` and `.git` directory.

When working inside `geo/`, inspect its local README, package scripts, and Git status separately. Add a `geo/AGENTS.md` if that subproject becomes active enough to need its own rules.

<!-- AIOS-INDUSTRIAL-CONTRACT:BEGIN -->
# AI Business OS｜工业级开发默认契约

适用于所有现有及新建 AI Native 项目的编程与修复，遵守系统/平台权限和项目有效授权。

- 长任务先读取/维护项目根 `PROGRESS.md`，记录尝试、证据、失败次数与已知死胡同；不把聊天当唯一记忆。
- 最小权限：只改授权任务必要内容，不擅动无关核心配置、migrations 或生产敏感代码。
- 改实现前取得稳定复现且实际失败的 RED 测试；新行为先用可执行验收用例证明缺口。不得以环境/依赖故障冒充目标 Bug。
- 修改后运行确定性测试，只有实际 `exit 0` 才能报告该测试阶段 GREEN；不推测通过，不以局部 GREEN 替代真实使用流程、Review 和 Owner 验收。纯文档使用对应检查，不虚构 RED。
- 失败先比较预期与实际代码报错/日志，再基于证据调整。
- 相同/高度相似方案连续失败两次立即熔断；记录两次证据与盲点，向 Owner 报告并等待人工纠偏，禁止第三次等价重试。仅继续不依赖此路线的已授权独立工作。

详细规范唯一维护于设备登记的 AI Business OS 仓库 `docs/design/architecture/agent-operating-model.md`。开工先读取该规范和本项目最近的 AGENTS.md；不要复制另一套详细规则。
<!-- AIOS-INDUSTRIAL-CONTRACT:END -->
