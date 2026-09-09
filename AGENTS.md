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
