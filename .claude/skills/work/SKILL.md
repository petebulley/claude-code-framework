---
description: Start a work session — pick up a task from the backlog or work on something new (bug fix, feature, tweak, refactor)
---

# Work

You are helping the user work on the project. This is the skill used for all ongoing development after the initial build — bug fixes, new features, tweaks, and refactors. Each session runs in an isolated git worktree so that multiple `/work` sessions can run concurrently on different tasks without interfering with each other. It ensures that the same principles from the initial build (plan before code, tests alongside code, documentation as you go) apply to every change, scaled appropriately to the size of the work.

**Prerequisites:**
- The project must have been through at least the initial build phases
- `CLAUDE.md` must exist (project conventions)
- `docs/tasks.md` must exist (task backlog)
- `docs/definition/master-plan.md`, `docs/definition/design-guidelines.md`, and `docs/definition/stack.md` should exist

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

### Adapt to ways of working

Read the `## Ways of Working` section from `CLAUDE.md` and the `# User Preferences` section from `~/.claude/CLAUDE.md` (if it exists). These preferences shape how this skill operates:

- **Technical level** — affects diagnosis presentation depth in Step 3 and summary detail.
- **Communication verbosity** — affects plan presentations, diagnoses, and completion summaries. Concise users get one-liners; detailed users get the full breakdown.
- **Collaboration style** — affects approval gates. For **delegative** users: skip the "Sound right?" confirmation for bug fixes and tweaks — just fix and report. For **collaborative** users (or not set): present the diagnosis/plan and wait for approval as currently written.
- **Git workflow** — if "Direct to main", skip worktree creation entirely and work directly on main. Commit directly instead of using branches and PRs. If "Branches" (or not set), use worktrees as currently written.
- **Testing depth** — passed to the phase-planner agent for new features.

If these preferences are not set, use defaults: Developer, Detailed, Collaborative, Branches, Practical.

## Step 0: Start worktree

**If the user's git workflow is "Direct to main":** skip this step entirely. Work directly on main — no worktree, no branches, no PRs. At the end of the session (Step 8), commit directly to main instead of creating a PR.

**If the user's git workflow is "Branches" (or not set):**

Each `/work` session runs in an isolated git worktree so that multiple sessions can work on different tasks concurrently without interfering with each other.

Explain the approach to the user:

> **Work sessions use isolated branches**
>
> Each `/work` session runs on its own branch via a git worktree. This means:
> - All your changes are isolated from main until you're ready
> - You can run multiple `/work` sessions in parallel on different tasks
> - When we're done, I'll merge your branch back to main
>
> Let's pick what to work on, then I'll create the branch.

**Don't enter the worktree yet** — wait until Step 1 completes so the branch can be named after the task (e.g. `fix-auth-redirect`, `feature-export-csv`).

If already in a worktree (e.g. the user manually entered one), skip this step and proceed normally.

## Step 1: What are we working on?

Start every session by asking the user what they want to work on:

> **What would you like to work on?**
>
> 1. **Pick from the task list** — I'll show you open tasks, bugs, and failed UAT tests
> 2. **Something new** — describe what you want to build, fix, or change

### Option 1: Pick from the task list

Read `docs/tasks.md` and find all incomplete items — tasks marked ⬜ (Not Started), 🟧 (In Progress), or 🟥 (Blocked). Also read `docs/uat.md` and find any tests marked ❌ (Failed).

Present them grouped by type:

> **Open work items:**
>
> **Blocked / Failed UAT** (fix these first)
> - 🟥 [Task description] — [reason blocked]
> - ❌ UAT-X.X: [Test name] — [failure notes]
>
> **In Progress** (previously started)
> - 🟧 [Task description]
>
> **Not Started**
> - ⬜ [Task description]
> - ⬜ [Task description]
> - ...
>
> Which item would you like to work on? Or would you prefer to work on something not on the list?

Let the user pick an item. If they pick a failed UAT test, treat it as a bug fix.

### Option 2: Something new

Ask the user to describe what they want to do. Then classify the work:

- **Bug fix** — something is broken or behaving incorrectly
- **New feature** — new functionality not yet in the codebase
- **Tweak** — a small change to existing behaviour, UI, or copy
- **Refactor** — restructuring code without changing behaviour

Confirm the classification with the user:

> That sounds like a **[bug fix / new feature / tweak / refactor]**. Is that right?

### Enter worktree

Now that the task is identified, use `EnterWorktree` to create an isolated worktree. Name the branch descriptively based on the task — e.g. `fix-login-redirect`, `feature-dark-mode`, `refactor-auth-middleware`, `tweak-button-spacing`.

If already in a worktree, skip this.

## Step 2: Understand the context

Before touching any code, build your understanding of the relevant area:

1. **Read `CLAUDE.md`** — project conventions, commands, structure
2. **Read relevant code** — explore the area of the codebase affected by this change
3. **Read the design guidelines** — if the change involves UI work
4. **Check `docs/decisions/`** — for any ADRs that affect the area you're working in
5. **Check `docs/plans/`** — for any existing plans that relate to this work

For **bug fixes**, also:
- Understand the expected vs actual behaviour
- Identify where the bug likely lives
- Check if there are existing tests that should have caught it

For **new features**, also:
- Read the master plan to understand if this feature was planned
- Identify which existing patterns to follow
- Consider how it integrates with what already exists

Present a brief summary:

> **Understanding:**
> - [What the change involves]
> - [Which files/areas are affected]
> - [Any relevant conventions or patterns to follow]
> - [Any design guidelines that apply]

## Step 3: Plan (scale to the work)

The depth of planning depends on the type and size of work.

### Bug fixes

No plan document needed. Instead, state your diagnosis and proposed fix:

> **Bug diagnosis:**
> - **Expected:** [what should happen]
> - **Actual:** [what happens instead]
> - **Cause:** [what's causing it]
> - **Fix:** [what you'll change]
> - **Tests:** [what tests you'll add to prevent regression]
>
> Sound right? I'll fix it and add a regression test.

If the user's collaboration style is **delegative**, skip the "Sound right?" confirmation — proceed directly to the fix and report the result. If **collaborative** (or not set), wait for approval as above.

### Tweaks

No plan document needed. State what you'll change:

> **Tweak:**
> - [What you'll change and where]
> - [Any tests to update]
>
> I'll make this change now.

### Refactors

No plan document needed, but state the approach clearly:

> **Refactor approach:**
> - **Goal:** [what the refactor achieves — e.g., "extract shared validation logic"]
> - **Scope:** [which files/modules are affected]
> - **Behaviour change:** None — existing tests should continue to pass
> - **New tests:** [any new tests needed]
>
> I'll refactor and verify all existing tests still pass.

### New features

Delegate planning to the **phase-planner agent**. Use the Agent tool to launch the `phase-planner` agent, providing:
- The feature name and description
- Your context summary from Step 2 (affected areas, relevant patterns, design guidelines)

The agent reads all prerequisite documents itself and returns a complete plan document plus a task count summary. Write the plan to `docs/plans/feature-[name].md`.

The plan should follow this structure:

```markdown
# Feature: [Name]

**Date:** [Current date]
**Status:** In Progress
**Origin:** [Task list item / user request / UAT feedback]

---

## Goal

[What this feature delivers and why]

## Design

[How it integrates with the existing application — UI placement, data model changes, API changes]
[Reference design guidelines where relevant]

## Implementation

### Tasks
- [ ] [Specific, actionable task]
- [ ] [Specific, actionable task]
- [ ] ...

### Tests
- [ ] [Specific test to write]
- [ ] ...

## UAT Scenarios

- [ ] UAT-X.X: [Scenario for docs/uat.md]
```

Present the plan for approval:

> **Feature plan written to `docs/plans/feature-[name].md`.**
>
> **[Count] tasks:**
> - [Brief summary of each area]
>
> Please review. Once you're happy, I'll add the tasks to `docs/tasks.md` and start implementing.

Wait for approval before proceeding.

## Step 4: Add to task list

For **new features**: add tasks to `docs/tasks.md` under a new section:

```markdown
## Feature: [Name]

- ⬜ [Task description]
- ⬜ [Task description]
- ⬜ [Test task]
```

For **bug fixes**: add a single task to `docs/tasks.md` if one doesn't already exist:

```markdown
- ⬜ Fix: [Bug description]
```

For **tweaks and refactors**: add a task if it's worth tracking, skip if it's trivial.

## Step 5: Implement

Work through the change, following the project's conventions from `CLAUDE.md`.

### All work types

- **Follow established patterns** — look at how the existing codebase handles similar things
- **Write tests alongside code** — not after, not later, alongside
- **Update `docs/tasks.md`** as you complete tasks (⬜ → 🟧 → 🟩)
- **Follow the design guidelines** for any UI work
- **Use Playwright MCP** (if available) to visually verify UI changes

### Bug fixes specifically

1. Write a failing test that reproduces the bug first (where practical)
2. Fix the bug
3. Verify the test now passes
4. Run the full test suite to check for regressions

### New features specifically

1. Work through tasks in order, marking each as done
2. Write tests for each piece as you go
3. Record any non-trivial technical decisions as ADRs in `docs/decisions/`
4. Add UAT scenarios to `docs/uat.md` for user-facing features

### Scope control

If during implementation you spot other issues, unrelated improvements, or "while I'm here" temptations:

> I noticed [issue/opportunity] while working on this. I'll log it as a new task rather than expanding scope. You can use `/new-issue` to capture it, or I can add it to `docs/tasks.md` now.

Don't scope-creep. Log it and stay focused on the current work.

## Step 6: Verify

After implementation:

1. **Run the full test suite** — all tests must pass, not just the new ones
2. **Run lint and type checks** — must be clean
3. **Run the build** — must succeed
4. **Visually verify** (if UI work and Playwright MCP is available) — open the app and check
5. **Run code review** — use the Agent tool to launch the `code-reviewer` agent. It reviews all changes for scope drift, convention adherence, quality issues, security concerns, and test coverage gaps. Handle findings by category:
   - **Must fix**: Fix these immediately without asking the user
   - **Should fix**: Present these as a batch and ask the user which to address
   - **Consider**: Note these but don't act unless the user asks

Use the exact commands from `CLAUDE.md` or the project's package.json/Makefile.

If anything fails, fix it before proceeding.

## Step 7: Document

Update documentation based on the type of work:

### Always
- **`docs/tasks.md`** — mark tasks as 🟩 Done
- **`docs/changelog.md`** — add an entry describing what changed

### For new features
- **`docs/uat.md`** — add UAT scenarios for the new feature
- **`docs/decisions/`** — write ADRs for any non-trivial decisions made
- **`CLAUDE.md`** — update if new patterns or conventions were established
- **`docs/definition/master-plan.md`** — update if the feature changes the product scope

### For bug fixes
- **`docs/uat.md`** — update the failed UAT test if the fix addresses one

### Changelog format

```markdown
## [Date]

- [Type: Fixed/Added/Changed/Removed] [Brief description of what changed]
```

## Step 8: Present summary and next steps

> **Work complete: [Brief title]**
>
> **Type:** [Bug fix / New feature / Tweak / Refactor]
> **What changed:** [1-3 bullet summary]
> **Tests:** [Count] new/updated tests — all passing
> **Documentation:** [What was updated]
>
### Merge to main

**If the user's git workflow is "Direct to main":** skip the worktree merge flow below. All changes are already on main. Commit directly and present the summary. Skip to "Next steps" below.

**If the user's git workflow is "Branches" (or not set):**

With the work complete and verified, merge the worktree branch back to main.

#### 1. Detect environment

Check whether we're in a worktree:

```bash
[ -f .git ] && echo "worktree" || echo "main repo"
```

If `.git` is a file (not a directory), we're in a worktree. This determines the merge strategy below.

#### 2. Sync with main (worktree only)

**This is the critical safety step.** If in a worktree, sync with the latest main before pushing — this prevents one worktree from silently overwriting another's changes:

```bash
git fetch origin main && git merge origin/main
```

If there are merge conflicts, **STOP and help the user resolve them**. Conflicts here mean another worktree (or direct work on main) changed the same files. Resolving them now is what prevents silent overwrites later.

**Never** run `git checkout main` in a worktree — it will fail because main is checked out in the main working directory.

#### 3. Rename branch

Worktree branches are created as `claude/<worktree-name>`. Rename to follow project conventions before pushing:

| Work type | Branch prefix | Example |
|-----------|--------------|---------|
| Bug fix | `fix/` | `fix/login-redirect` |
| Feature | `feature/` | `feature/dark-mode` |
| Refactor | `refactor/` | `refactor/auth-middleware` |
| Tweak | `tweak/` | `tweak/button-spacing` |

```bash
git branch -m <new-branch-name>
```

If the branch is already named correctly (e.g. the user named it manually), skip the rename.

#### 4. Push and create PR

```bash
git push -u origin <branch-name>
gh pr create --base main --title "<PR title>" --body "<description>"
```

The PR title should be a concise summary of the work. The body should include what changed and how it was tested.

Present the PR to the user:

> **PR created: [PR title]**
>
> [PR URL]
>
> Would you like to:
> 1. **Merge now** — I'll merge the PR and clean up the branch
> 2. **Wait for review** — keep the PR open for review

If the user chooses to merge now:

```bash
gh pr merge --merge --delete-branch
```

> **Merged** — PR merged and branch cleaned up.

If the user wants to wait for review, leave the PR open.

#### 5. Exit worktree

Use `ExitWorktree` to return to the main working directory.

#### Fallback: direct merge (main repo only)

If the session was **not** in a worktree (e.g. working directly on a branch in the main repo), use direct merge as a fallback:

1. Ensure all changes are committed
2. `git checkout main && git merge <branch-name>`
3. If the merge is clean, delete the branch: `git branch -d <branch-name>`
4. If there are merge conflicts, help the user resolve them

> **Merged to main** — branch `<branch-name>` has been merged and cleaned up.

**Never** use direct merge from a worktree — always use the PR flow above.

> **Next steps:**
> - **Deploy** — run `/deploy-[project]` to push this to production
> - **UAT** — run `/uat` to test [new/fixed feature] in production
> - **Continue working** — run `/work` to pick up the next task
> - **Log an issue** — run `/new-issue` to capture something for later

## Guidelines

### Scaling process to work size

The key principle is that the process overhead should match the size of the change:

| Work type | Plan doc? | Tasks in tasks.md? | ADR? | UAT scenarios? |
|-----------|-----------|---------------------|------|----------------|
| Bug fix | No | Yes (single task) | Rarely | Update if UAT failed |
| Tweak | No | Optional | No | No |
| Refactor | No | Optional | If significant | No |
| New feature | Yes | Yes (full task list) | If decisions made | Yes |

### Worktree safety rules
- **Never** `git checkout main` in a worktree — it will fail and is never needed
- **Never** direct merge from a worktree — always use the PR flow
- **Always** sync with main (`git fetch origin main && git merge origin/main`) before pushing from a worktree — this is the primary mechanism that prevents parallel worktrees from silently overwriting each other's changes
- Conflicts during the sync step are **expected and valuable** — they mean another worktree changed the same files, and resolving them now prevents data loss

### What NOT to do
- Do NOT skip reading the codebase before making changes — understand first, then modify
- Do NOT skip tests — every change gets tests, no matter how small
- Do NOT scope-creep — log other issues via `/new-issue`, stay focused
- Do NOT skip the verification step — all tests, lint, and build must pass
- Do NOT forget to update `docs/tasks.md` — it's the source of truth for work status
- Do NOT forget the changelog — every change should be logged
- Do NOT ignore the design guidelines for UI work — consistency matters
- Do NOT make undocumented technical decisions — if it's non-trivial, write an ADR
