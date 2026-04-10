---
description: Check the current status of the project — where it stands, what's done, what's outstanding, and what to do next
---

# Status

You are giving the user a snapshot of where the project stands. This is a read-only skill — you don't change anything, you just report and recommend.

**Adapt to verbosity:** Read `~/.claude/CLAUDE.md` for the user's communication verbosity. **Concise** users get the tables, recommendation, and nothing else — skip the recent activity section and keep commentary to one line. **Detailed** users (or not set) get the full report as written below.

Useful for:
- Starting a new session and orienting yourself
- Coming back to a project after a break
- Deciding what to work on next
- Getting a quick health check before a demo or deployment

### Pre-step: Check for framework updates

Before starting, check if the framework has updates available:

```bash
SKILL_LINK=$(readlink ~/.claude/skills/work 2>/dev/null) && \
FRAMEWORK_DIR=$(dirname "$(dirname "$(dirname "$SKILL_LINK")")") && \
[ -f "$FRAMEWORK_DIR/bin/check-update.sh" ] && \
bash "$FRAMEWORK_DIR/bin/check-update.sh"
```

- If the output says **UPDATE AVAILABLE**, tell the user and offer to update now. If they agree, run the same command with `--pull` at the end.
- If there is no output, continue silently — the framework is up to date (or offline).

## Step 1: Determine the project phase

Check which documents exist to understand where the project is in the framework process:

| Document | Exists? | Implies |
|----------|---------|---------|
| `docs/definition/master-plan.md` | | `/start-project` complete |
| `docs/definition/stack.md` | | `/cto` complete |
| `docs/definition/implementation-plan.md` | | `/cto` complete |
| `CLAUDE.md` | | `/cto` complete |
| `docs/definition/design-guidelines.md` | | `/designer` complete |
| `docs/definition/design-system.html` | | `/designer` complete |
| `docs/tasks.md` | | Implementation started |
| `docs/deployment/first-time-setup.md` | | `/first-deploy` complete |
| `.claude/skills/deploy-*/SKILL.md` | | Project deploy skill exists |
| `docs/uat.md` | | UAT scenarios defined |

Classify the project into one of these states:

- **Not started** — no docs exist yet. Recommend `/start-project`.
- **Planning** — master plan exists but no stack/implementation plan. Recommend `/cto`.
- **Designing** — stack exists but no design guidelines. Recommend `/designer`.
- **Building** — implementation plan exists, phases are in progress. Report phase progress. Recommend `/implement`.
- **Ready to deploy** — phases complete but no deployment setup. Recommend `/first-deploy`.
- **In UAT** — deployed, UAT scenarios exist with incomplete tests. Recommend `/uat`.
- **Ongoing development** — initial build and UAT complete, project is in maintenance/growth mode. Recommend `/work`.

## Step 2: Gather the numbers

Read the relevant files and compile statistics. Only include sections that are relevant to the project's current phase.

### Implementation progress (if building)

Read `docs/definition/implementation-plan.md` and `docs/tasks.md` to build a phase-by-phase summary:

| Phase | Name | Status | Tasks |
|-------|------|--------|-------|
| 0 | Project Foundation | Done | 15/15 |
| 1 | Auth & Multi-Tenancy | Done | 22/22 |
| 2 | App Shell | In Progress | 8/18 |
| 3 | Calendar Integration | Not Started | 0/0 |

Count tasks by status indicator: ⬜ Not Started, 🟧 In Progress, 🟩 Done, 🟥 Blocked.

### Task backlog (if tasks exist)

Read `docs/tasks.md` and summarise open items:

| Type | Count |
|------|-------|
| Bugs | X |
| Features | X |
| Improvements | X |
| Blocked | X |
| **Total open** | **X** |

### UAT progress (if UAT exists)

Read `docs/uat.md` and count by status:

| Status | Count |
|--------|-------|
| ✅ Passed | X |
| ❌ Failed | X |
| ⏳ In Progress | X |
| ⬜ Not Started | X |
| **Total** | **X (XX% complete)** |

### Recent activity

Read `docs/changelog.md` and show the last 3-5 entries to give a sense of momentum and recent work.

## Step 3: Present the status report

Combine everything into a concise report:

> **Project Status: [Project Name]**
>
> **Phase:** [Building / In UAT / Ongoing Development / etc.]
>
> ---
>
> **Implementation Progress**
> [Phase table — only if in building phase]
> [X of Y phases complete, currently on Phase N: Name]
>
> **Open Tasks**
> [Task summary table]
> [Highlight any blocked items]
>
> **UAT**
> [UAT summary — X/Y tests passed (XX%)]
> [List any failed tests by name]
>
> **Recent Activity**
> - [Date]: [Change summary]
> - [Date]: [Change summary]
> - [Date]: [Change summary]
>
> ---
>
> **Recommended next step:** [Specific skill recommendation with reasoning]
> - `/implement` — continue with Phase N: [Name]
> - `/work` — pick up one of the X open tasks
> - `/uat` — X tests remaining
> - `/deploy-[project]` — deploy recent changes
> - [etc.]

### Recommending the next step

Be specific about what to do next based on what you found:

- **Blocked tasks exist** → "There are X blocked tasks. Consider unblocking these first with `/work`."
- **Failed UAT tests** → "X UAT tests have failed. Run `/uat` to retest after fixes, or `/work` to fix the underlying issues."
- **Implementation phase in progress** → "Phase N is X% complete. Run `/implement` to continue."
- **All phases done, not deployed** → "All implementation phases are complete. Run `/first-deploy` to set up deployment."
- **Everything green, open backlog** → "Project is healthy. X open tasks in the backlog — run `/work` to pick one up."
- **Everything green, no open tasks** → "Project is up to date with no open tasks. Nice work!"

## Guidelines

- **Read-only** — don't modify any files, don't fix issues, don't start work. Just report.
- **Be concise** — this is a dashboard, not a deep dive. Tables over paragraphs.
- **Be specific in recommendations** — don't just say "run `/work`", say "run `/work` to fix the 3 open bugs" or "run `/implement` to continue Phase 4: Notifications".
- **Highlight problems** — blocked tasks, failed UAT tests, and stale in-progress items should stand out.
- **Skip empty sections** — if there are no open tasks, don't show a task table with all zeros. Only show what's relevant.
