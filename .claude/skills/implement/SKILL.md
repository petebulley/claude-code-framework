---
description: Implement a phase of the project, one phase at a time, with planning, testing, and documentation
---

# Implement

You are implementing the project following the implementation plan. By default, each invocation works on a single phase — but the user can choose fully autonomous mode to keep working through phases without interruption, using worktrees to implement independent phases in parallel where possible. You plan before you code, you test as you go, and you keep all documentation up to date.

**Prerequisites:** The following documents must exist before running this skill:
- `docs/definition/master-plan.md` — the product specification
- `docs/definition/implementation-plan.md` — the phased build plan
- `docs/definition/stack.md` — the tech stack reference
- `docs/definition/design-guidelines.md` — the design system specification
- `CLAUDE.md` — project conventions

If any are missing, tell the user which step to run first (`/start-project`, `/cto`, or `/designer`).

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

- **Technical level** (from `~/.claude/CLAUDE.md`) — affects local testing guide detail in Step 7. Developers get terse commands; non-technical users get step-by-step walkthroughs.
- **Communication verbosity** (from `~/.claude/CLAUDE.md`) — affects plan presentation depth in Step 3 and completion summaries in Step 7. Concise users get headlines with a link to the plan file; detailed users get the full task listing.
- **Collaboration style** (from `CLAUDE.md`) — affects the execution mode presentation in Step 1. Delegative users see autonomous mode listed first as the recommended option; collaborative users see one-at-a-time first (as currently written).
- **Git workflow** (from `CLAUDE.md`) — affects worktree usage. If "Direct to main", skip worktree creation for parallel phases and work sequentially on main. Parallel execution with worktrees is only used with "Branches" workflow.
- **Testing depth** (from `CLAUDE.md`) — passed to the phase-planner agent in Step 3 so it generates the right volume of test tasks (comprehensive = edge cases + high coverage; practical = critical paths; minimal = likely-to-break only).

If these preferences are not set, use defaults: Developer, Detailed, Collaborative, Branches, Practical.

## Step 1: Show progress and identify the next phase

Read `docs/definition/implementation-plan.md` and `docs/tasks.md` to understand:
- Which phases exist in the plan
- Which phases are complete (all tasks marked done in tasks.md)
- Which phase is currently in progress (if any)
- Which phase is next

Present the user with a progress overview:

> **Implementation Progress**
>
> | Phase | Name | Status |
> |-------|------|--------|
> | 0 | Project Foundation | Done |
> | 1 | Auth & Multi-Tenancy | Done |
> | 2 | App Shell & Navigation | In Progress (12/18 tasks) |
> | 3 | Google Calendar Integration | Not Started |
> | ... | ... | ... |
>
> **Next up:** Phase 2 — App Shell & Navigation (continuing) / Phase 3 — Google Calendar Integration
>
> Ready to work on Phase [N]?

If a phase is partially complete, offer to continue it. If all tasks in the current phase are done, move to the next.

The user can also request a specific phase if they want to work out of order (though dependencies should be respected).

### Choose execution mode

After showing the progress table, ask the user how they'd like to proceed. If the user's collaboration style is **delegative**, present autonomous mode first as the recommended option. If **collaborative** (or not set), present one-at-a-time first:

> **How would you like to proceed?**
>
> 1. **One phase at a time** (default) — I'll implement this phase, then stop for your review
> 2. **Fully autonomous** — I'll keep working through phases without stopping, using worktrees for parallel phases where possible

If the user chooses **fully autonomous mode**:
- After completing each phase (Step 7), loop back to Step 1 to identify and begin the next phase automatically
- Check for parallelisable phases (see below) and use worktrees to implement them concurrently
- **Stop conditions:** all phases are complete, or a blocker requires user input (ambiguity in the plan, external dependency, conflict with master plan or design guidelines)
- Still present the Step 7 completion summary for each phase so the user can see progress, but continue immediately rather than waiting

### Detect parallelisable phases (autonomous mode only)

When in autonomous mode, after identifying remaining incomplete phases:

1. Read the Phase Summary table in `docs/definition/implementation-plan.md`, specifically the `Depends on` column
2. Find all phases whose dependencies are fully satisfied (every phase listed in their `Depends on` column is marked complete)
3. If **multiple phases** are ready simultaneously, they can be implemented in parallel

**Parallel execution:**

Present the opportunity:

> **Parallel phases detected**
>
> These phases have all dependencies satisfied and can run concurrently:
> - Phase [N]: [Name] (depends on: Phase [X] ✓)
> - Phase [M]: [Name] (depends on: Phase [X] ✓)
>
> I'll implement these in parallel using isolated worktrees, then merge the results.

Use the **Agent tool with `isolation: "worktree"`** to spawn one subagent per parallel phase. Each subagent receives:
- The full phase specification from the implementation plan
- Project conventions from `CLAUDE.md`
- Design guidelines, stack reference, and master plan context
- Instructions to execute Steps 2–7 of this skill for their assigned phase
- Instructions to skip user approval gates (plan review in Step 3, task approval in Step 4) since the user has opted into autonomous execution

Wait for all subagents to complete, then merge their branches back to main sequentially using the PR flow:

For each completed worktree branch:
1. **Sync with main** — the subagent's worktree may be stale if an earlier branch was already merged. From the worktree (or by checking it out), run `git fetch origin main && git merge origin/main`. If there are conflicts, resolve them — documentation files (`docs/tasks.md`, `docs/uat.md`, `docs/changelog.md`) will likely conflict and should be resolved by combining both sides. For code conflicts, attempt auto-resolution; if unable, flag to the user and pause autonomous execution.
2. **Rename the branch** from `claude/<name>` to `feature/<phase-name>` (e.g. `feature/phase-3-calendar-integration`)
3. **Push and create PR** — `git push -u origin <branch>` then `gh pr create --base main`
4. **Merge the PR** — `gh pr merge --merge --delete-branch` (in autonomous mode, merge immediately rather than waiting for review)

After all parallel branches are merged via PRs, present a combined summary:

> **Parallel phases complete**
>
> | Phase | Name | Tasks | Status |
> |-------|------|-------|--------|
> | [N] | [Name] | [X]/[X] | Merged ✓ |
> | [M] | [Name] | [Y]/[Y] | Merged ✓ |
>
> All branches merged successfully. Continuing to next phase...

Then loop back to Step 1 to identify the next set of phases.

If only **one phase** is ready, proceed with it normally through Steps 2–7 (no worktree needed for a single phase).

**Git workflow note:** If the user's git workflow is "Direct to main", skip worktree-based parallel execution entirely. Implement phases sequentially on main, committing directly. The parallel detection and PR merge flow above only applies to "Branches" workflow.

## Step 2: Understand the current state

Before planning, build a thorough understanding of the project as it stands. Read:

1. **The phase specification** from `docs/definition/implementation-plan.md` — what this phase should deliver
2. **The master plan** — the relevant feature sections this phase implements
3. **The design guidelines** — any UI/UX details relevant to this phase
4. **The stack reference** — technologies and conventions to follow
5. **CLAUDE.md** — project conventions and rules
6. **Existing code** — explore the codebase to understand what's already built, the patterns in use, and how the new phase integrates
7. **Previous phase plans** — check `docs/plans/` for plans from earlier phases to understand established patterns
8. **Recent ADRs** — check `docs/decisions/` for any decisions that affect this phase

Summarise your understanding to the user:

> **Phase [N]: [Name]**
>
> **Goal:** [What this phase delivers]
> **Builds on:** [What already exists from previous phases]
> **Key areas:** [List the main things to implement]
> **Design considerations:** [Any specific design guidelines to follow]
> **Technical notes:** [Any technical patterns or decisions to be aware of]

## Step 3: Create the phase plan

Delegate planning to the **phase-planner agent**. Use the Agent tool to launch the `phase-planner` agent, providing:
- Which phase to plan (number and name)
- Your context summary from Step 2 (goal, what's built, key areas, technical notes)
- The **testing depth** preference (comprehensive / practical / minimal) so the agent calibrates test task volume accordingly

The agent reads all prerequisite documents itself and returns a complete plan document plus a task count summary.

Write the agent's plan to `docs/plans/phase-[N]-[name].md`. The plan should follow this structure:

### Plan structure

```markdown
# Phase [N]: [Name] — Implementation Plan

**Date:** [Current date]
**Status:** In Progress
**Source:** implementation-plan.md Phase [N]

---

## Goal

[One paragraph describing what this phase delivers and why it matters]

## Prerequisites

[What must be in place before this phase starts — previous phases, external setup, etc.]

## Implementation Details

### [N].1 [Sub-section name]

[Detailed description of what to build, referencing master plan and design guidelines]

**Tasks (red-green-refactor):**
- [ ] Write failing tests for [specific behaviour]
- [ ] Implement [specific thing] to make tests pass
- [ ] Write failing tests for [next behaviour]
- [ ] Implement [next thing] to make tests pass
- [ ] ...

### [N].2 [Sub-section name]

...

## Testing

The red-green-refactor cycle is embedded in each sub-section's tasks above. This section covers cross-cutting and integration-level verification.

### Integration Tests
- [ ] [Specific cross-cutting test]
- [ ] ...

### Manual Verification
- [ ] [Specific thing to verify]
- [ ] ...

## User Acceptance Tests

Define UAT scenarios for this phase to be added to `docs/uat.md`. These will be conducted by the user in production after deployment.

- [ ] UAT-[N].1: [Scenario title]
- [ ] UAT-[N].2: [Scenario title]
- [ ] ...

## Documentation Updates

- [ ] [ADR to write, if any technical decisions are made]
- [ ] Update `docs/tasks.md` with phase tasks
- [ ] Update `docs/uat.md` with UAT scenarios for this phase
- [ ] Update `docs/changelog.md` with phase completion
- [ ] Update `CLAUDE.md` if new conventions or patterns are established
- [ ] Update implementation plan to mark phase status

## Security Considerations

[Brief assessment of security-relevant changes in this phase, or "No security-relevant changes in this phase."]

## Dependencies & Risks

[Any risks, unknowns, or external dependencies for this phase]
```

### Planning principles

- **Tasks must be specific and actionable** — "Create the user settings page with theme toggle, notification preferences, and profile section" not "Build settings"
- **Tests come first in the plan, not alongside** — every sub-section lists its failing test tasks before the implementation tasks that make them pass (red-green-refactor)
- **Reference the design guidelines** — for any UI work, the plan should note which design tokens, components, and patterns to use
- **Reference the master plan** — link each piece of work back to the feature it implements
- **Note any decisions to make** — if the phase requires technical decisions, note them as ADRs to write
- **Include documentation tasks** — changelog, tasks.md updates, ADRs, and any updates to existing docs

### Present the plan for review

After writing the plan, present a summary to the user:

> **Phase [N] plan written to `docs/plans/phase-[N]-[name].md`.**
>
> **[Count] tasks across [count] sub-sections:**
> - [Sub-section 1]: [brief description] ([count] tasks)
> - [Sub-section 2]: [brief description] ([count] tasks)
> - ...
> - Testing: [count] test tasks
> - Documentation: [count] doc tasks
>
> **Decisions to make:** [list any ADRs needed]
> **Risks:** [list any risks]
>
> Please review the plan. Once you're happy, I'll add the tasks to `docs/tasks.md` and start implementing.

If the user prefers **concise** communication, shorten this summary to the task count and key risks only, with a pointer to the plan file for full detail. If **detailed** (or not set), show the full listing above.

Wait for the user to approve or request changes. Iterate on the plan if needed.

## Step 4: Add tasks to tasks.md

Once the plan is approved, add all tasks from the plan to `docs/tasks.md`.

### tasks.md format

Follow this format (matching the project's existing task file):

```markdown
## Phase [N]: [Name]

### [N].1 [Sub-section name]

- ⬜ [Task description]
- ⬜ [Task description]

### [N].2 [Sub-section name]

- ⬜ [Task description]

### [N].X Testing

- ⬜ [Test task]

### [N].Y Documentation

- ⬜ [Doc task]
```

**Status indicators:**
- ⬜ Not Started
- 🟧 In Progress
- 🟩 Done
- 🟥 Blocked

Add the new phase section to the end of the existing tasks.md content. Do not modify tasks from previous phases.

## Step 5: Implement

Work through the tasks in the plan, updating `docs/tasks.md` as you go.

### Implementation workflow

For each sub-section of the plan:

1. **Mark the first task as in progress** (🟧) in tasks.md
2. **Write a failing test** (red) — write a test that defines the expected behaviour. Run it and confirm it fails.
3. **Write the minimal code to pass** (green) — implement just enough to make the failing test pass. Follow the conventions in `CLAUDE.md`, established patterns, design guidelines, and stack reference.
4. **Refactor** — clean up the code you just wrote. The test gives you safety to refactor confidently.
5. **Repeat** for the next behaviour in this sub-section
6. **Mark the task as done** (🟩) in tasks.md when the sub-section is complete
7. **Move to the next sub-section**

**When TDD doesn't apply:** Some tasks are genuinely not test-first — initial project scaffolding, UI layout and styling, configuration files, exploratory spikes. For these, write tests after implementation or skip tests if there's no meaningful logic to test. Default to test-first.

### During implementation

- **Follow established patterns** — look at how previous phases solved similar problems. Maintain consistency.
- **Write tests before code (TDD)** — follow the red-green-refactor cycle. For each behaviour, write a failing test first, then implement to pass it, then refactor.
- **Record decisions** — if you make a non-trivial technical decision during implementation, write an ADR in `docs/decisions/`. Use the next available number.
- **Update existing docs** — if your implementation changes anything documented in the master plan, design guidelines, or stack reference, update those docs.
- **Keep tasks.md current** — update task status as you complete each task, not in batches.
- **Use Playwright MCP** (if available) — for UI work, open the app in the browser to visually verify components, layouts, and interactions match the design guidelines.

### Handling surprises

If during implementation you discover:
- **A gap in the plan** — add the missing task to both the plan and tasks.md, then implement it
- **A needed technical decision** — write an ADR, update the plan, and proceed
- **A conflict with the master plan or design guidelines** — flag it to the user and agree on the resolution before proceeding
- **A dependency on an unfinished phase** — flag it to the user, mark the task as blocked (🟥), and move to the next unblocked task
- **A bug in previous phase code** — fix it, add a test for it, and note it in the changelog

### Commit discipline

Follow the commit conventions established in the CTO step. Make logical, incremental commits as you complete sub-sections — don't accumulate a massive uncommitted changeset.

## Step 6: Write UAT scenarios

As part of completing the phase, define user acceptance test scenarios and add them to `docs/uat.md`. These are tests the user will conduct manually in production after deployment (via the `/uat` skill).

### UAT format

Each scenario follows this format in `docs/uat.md`:

```markdown
### UAT-[N].[X]: [Scenario Title]

**Status:** ⬜ Not Started

**Steps:**

1. [Specific action the user takes]
2. [Next action]
3. [Continue until the scenario is complete]

**Expected:**

- [What the user should see or experience]
- [Specific UI elements, data, or behaviour to verify]
- [Include mobile/responsive checks where relevant]
```

### What makes a good UAT scenario

- **User-focused** — written from the perspective of someone using the product, not a developer
- **Specific steps** — clear enough that anyone on the team can follow them
- **Observable outcomes** — the expected results are things the user can see and verify
- **Cover the key flows** — every significant feature the phase delivers should have at least one UAT scenario
- **Include edge cases** — error states, empty states, boundary conditions
- **Include responsive checks** — where relevant, note to test on mobile viewport too

Add the new phase's UAT scenarios to the end of the existing `docs/uat.md` content, under a section heading matching the phase name.

## Step 7: Phase completion

When all tasks for the phase are done:

1. **Verify all tasks are marked done** in tasks.md
2. **Run the full test suite** and fix any failures
3. **Run lint and type checks** and fix any issues
4. **Run code review** — use the Agent tool to launch the `code-reviewer` agent. It reviews all changes made during this phase for scope drift, convention adherence, quality issues, security concerns, and test coverage gaps. Handle findings by category:
   - **Must fix**: Fix these immediately without asking the user
   - **Should fix**: Present these as a batch and ask the user which to address
   - **Consider**: Note these but don't act unless the user asks
5. **Write UAT scenarios** for this phase in `docs/uat.md`
6. **Update the changelog** — add a section for this phase in `docs/changelog.md`
7. **Update the implementation plan** — mark this phase's status as complete
8. **Update CLAUDE.md** if new patterns, conventions, or important files were established
9. **Review and update tasks.md** — ensure all tasks are marked 🟩

### Definition of Done checklist

Before declaring a phase complete, verify every item:

- [ ] All plan tasks completed and marked 🟩 in `docs/tasks.md`
- [ ] All tests passing (full suite, not just new tests)
- [ ] Lint and type checks clean
- [ ] Code review complete — all "Must fix" items resolved; "Should fix" items reviewed and dispositioned with user
- [ ] UAT scenarios written in `docs/uat.md` for user-facing changes
- [ ] Testability mechanisms built for any new roles, automated features, or integrations introduced in this phase (per `CLAUDE.md` testability conventions)
- [ ] `docs/changelog.md` updated with phase summary
- [ ] `CLAUDE.md` still accurate (new commands, conventions, patterns reflected)
- [ ] Implementation plan updated to mark phase as complete

If any item fails, address it before moving on. Don't skip items for speed — catching issues now is cheaper than catching them in UAT or production.

### Local testing guide

Adapt the detail level to the user's **technical level**. Developers get terse commands ("run `npm run dev` and check `/settings`"). Non-technical users get step-by-step instructions with explicit descriptions of what to look for. Technical-but-not-daily users get something in between.

Present a clear guide to the user on how to test this phase locally:

> **How to test Phase [N] locally:**
>
> 1. [Start the dev server: `npm run dev` or equivalent]
> 2. [Navigate to specific URL or page]
> 3. [Describe what to look for / interact with]
> 4. [Any specific flows to try]
> 5. [Any known limitations or things not yet wired up]
>
> **Issues resolved in this phase:**
> - [List any bugs fixed or issues encountered and resolved during implementation]

This helps the user verify the phase works before moving on, enabling early course correction.

Present a summary to the user:

> **Phase [N]: [Name] — Complete**
>
> **Tasks completed:** [count]
> **Tests written:** [count of new test files or test cases]
> **UAT scenarios added:** [count] scenarios in `docs/uat.md`
> **ADRs created:** [list any new ADRs]
> **Key changes:** [brief summary of what was built]
>
> All tests passing. Lint and type checks clean.
>
> **How to test locally:** [brief local testing instructions]
>
> Please test the phase locally and let me know if anything needs adjusting before we move on.

### What happens next depends on execution mode

**One-at-a-time mode (default):**

> **Next phase:** Phase [N+1] — [Name]. Run `/implement` when you're ready to continue.

If the implementation plan indicates this is a good point for deployment (e.g. after the foundation phase or after MVP phases are complete), suggest running `/first-deploy`:

> This is a good point to deploy to production. Run `/first-deploy` to create the deployment guide and set up the project deploy skill.

**Autonomous mode:**

If there are remaining incomplete phases, display a brief transition and loop back to Step 1:

> **Continuing autonomously to Phase [N+1]: [Name]...**

If all phases are complete, present a final summary:

> **All phases complete**
>
> The implementation plan is fully complete. All [count] phases have been implemented, tested, and documented.
>
> **Next steps:**
> - Run `/uat` to walk through acceptance tests in production
> - Run `/first-deploy` if not yet deployed
> - Run `/status` for a full project overview

If a blocker is encountered during autonomous execution (ambiguity, external dependency, conflict with master plan), pause and explain:

> **Autonomous execution paused**
>
> [Explanation of the blocker]
>
> Please resolve this and run `/implement` to resume.

## Guidelines

### Quality standards
- Every piece of code should have corresponding tests, written before the implementation (red-green-refactor)
- All tests must pass before marking a phase complete
- Lint and type checks must be clean
- Code must follow the conventions in CLAUDE.md
- UI must match the design guidelines

### Documentation discipline
- Update tasks.md in real-time, not at the end
- Write ADRs for non-trivial decisions as they happen
- Update the changelog at phase completion
- Keep the implementation plan status current
- Update CLAUDE.md when new patterns are established

### Communication
- Show progress clearly — the user should always know what you're working on and what's next
- Flag blockers immediately — don't silently skip tasks
- Ask for clarification when the plan or master plan is ambiguous rather than guessing

### Worktree safety rules (parallel phases)
- **Never** `git checkout main` in a worktree — it will fail and is never needed
- **Never** direct merge from a worktree — always use the PR flow (push, `gh pr create`, `gh pr merge`)
- **Always** sync with main before pushing each parallel branch — this is critical when merging the second (and subsequent) branches, since the first branch's merge will have changed main
- Conflicts during sync are **expected** for parallel phases — especially in shared docs files. Resolve by combining both sides.

### What NOT to do
- Do NOT skip writing tests — every phase includes tests, written before the code they verify (red-green-refactor)
- Do NOT implement multiple phases at once unless the user has chosen autonomous mode
- Do NOT skip the planning step — always create a plan in `/docs/plans` before coding
- Do NOT leave tasks.md stale — update it as you go
- Do NOT ignore the design guidelines — UI work must match the spec
- Do NOT make undocumented technical decisions — if it's non-trivial, write an ADR
- Do NOT batch all documentation to the end — document as you implement
- Do NOT skip UAT scenarios — every phase should define what the user will test in production
- Do NOT skip the local testing guide — the user needs to know how to verify the phase works
