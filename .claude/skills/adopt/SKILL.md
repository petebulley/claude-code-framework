---
description: Retroactively apply the framework to an existing project — audit what exists, identify gaps, and bring it into line
---

# Adopt

You are helping the user bring an existing project into the framework. The project already has code, possibly some documentation, and its own conventions. Your job is to understand what exists, map it against what the framework expects, and create a plan to bring the project into alignment — preserving what's good, reorganising what's misplaced, and creating what's missing.

This is NOT a greenfield setup. You are retrofitting, not starting from scratch. Respect the project's existing work, conventions, and history.

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

## Step 1: Understand the existing project

Delegate the initial audit to the **project-auditor agent**. Use the Agent tool to launch the `project-auditor` agent — it autonomously explores the entire project (structure, docs, conventions, tests, deployment, maturity) and returns a structured audit report.

While the agent runs, you can ask the user:

> "While I audit the project, what's your goal with adopting the framework? Are you looking for the full treatment (planning docs, design system, implementation plan) or mainly want the ongoing workflow (CLAUDE.md, task tracking, work/deploy skills)?"

When the agent returns, use its report to present your findings (see format below). Supplement with targeted follow-up reads if any area needs more detail.

Explore the project thoroughly before making any recommendations. Read and examine:

### 1.1 Project basics

- **What the project does** — README, landing page, package description
- **Language and framework** — package.json, requirements.txt, go.mod, Cargo.toml, etc.
- **Project structure** — directory layout, where source code lives, where tests live
- **Build and dev commands** — scripts in package.json, Makefile, etc.

### 1.2 Existing documentation

Look for documentation in common locations:

- `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`
- `docs/` directory (any structure)
- `CLAUDE.md` or `.cursorrules` or similar AI assistant config
- `.claude/` directory
- Inline documentation, JSDoc, docstrings
- Wiki or external docs (ask the user)

### 1.3 Existing conventions

Identify conventions already in use:

- **Code style** — linter config (ESLint, Biome, Ruff, etc.), formatter config (Prettier, Black, etc.)
- **Testing** — test framework, test file locations, naming conventions, coverage config
- **Git** — commit message style (check recent commits), branch strategy, hooks
- **CI/CD** — GitHub Actions, GitLab CI, etc.
- **Environment** — .env files, Docker, docker-compose
- **Deployment** — hosting platform, deploy scripts, infrastructure config

### 1.4 Project maturity

Assess where the project is:

- **Codebase size** — rough file/line count, number of features
- **Test coverage** — are there tests? How comprehensive?
- **Documentation state** — is it maintained, outdated, or missing?
- **Activity** — recent commits, open issues, active development?

Present your findings to the user:

> **Project audit: [Project Name]**
>
> **What it is:** [one-liner description]
> **Stack:** [language, framework, database, hosting]
> **Codebase:** [rough size — small/medium/large, file count]
> **Tests:** [framework, coverage level, co-located or separate]
> **Documentation:** [what exists, where it lives, condition]
> **Conventions:** [linter, formatter, commit style, etc.]
> **Deployment:** [how it's deployed, CI/CD]
>
> **First impression:** [any notable strengths or gaps you've spotted]

Ask the user:

> "Does this capture the project accurately? Anything I've missed or got wrong?"

If you haven't already received the user's adoption goals (asked while the agent was running), ask now:

> "What's your goal with adopting the framework? Are you looking for the full treatment (planning docs, design system, implementation plan) or mainly want the ongoing workflow (CLAUDE.md, task tracking, work/deploy skills)?"

This answer determines the scope of the adoption — not every project needs every framework artifact.

## Step 2: Map against the framework

Compare what exists against what the framework expects. Organise findings into three categories:

### 2.1 Exists and is fine

Things the project already has that align with framework expectations, even if named or located differently. These need no changes or only minor adjustments.

Examples:
- Has a linter and formatter configured → matches CTO conventions expectations
- Has tests co-located with source → matches testing conventions
- Has a README with project overview → content can feed into master plan
- Has CI/CD pipeline → matches deployment expectations

### 2.2 Exists but needs reorganising

Things the project has but that are in the wrong place, named differently, or structured differently from what the framework expects. These need moving, renaming, or restructuring — but the content is already there.

Examples:
- Documentation scattered across README sections → consolidate into `docs/` structure
- Technical decisions discussed in comments/PRs but not recorded → capture as ADRs
- Task tracking in GitHub Issues → mirror key items to `docs/tasks.md`
- Existing style guide → restructure as `docs/definition/design-guidelines.md`

### 2.3 Missing and needs creating

Things the framework expects that don't exist at all. These need to be created, but should be informed by the existing project rather than written from a blank slate.

Examples:
- No `CLAUDE.md` → create from existing conventions and project knowledge
- No master plan → create from README, existing features, and user input
- No implementation plan → create reflecting current state (completed phases) and future work
- No `docs/tasks.md` → create from existing issues/TODOs
- No design guidelines → create from existing UI patterns (if frontend project)
- No ADRs → create retroactive ADRs for key decisions already made
- No changelog → create from git history
- No UAT scenarios → create from existing features

Present the mapping as a clear table:

> **Framework alignment:**
>
> | Framework artifact | Status | What exists | Action needed |
> |---|---|---|---|
> | `CLAUDE.md` | Missing | `.cursorrules` with some conventions | Create from existing + expand |
> | `docs/definition/master-plan.md` | Missing | README has overview and features | Create from README + conversation |
> | `docs/definition/stack.md` | Missing | package.json, tsconfig | Generate from project config |
> | `docs/definition/implementation-plan.md` | Missing | — | Create reflecting current state |
> | `docs/definition/design-guidelines.md` | Partial | Tailwind config has design tokens | Extract and document |
> | `docs/tasks.md` | Missing | GitHub Issues (12 open) | Create from issues |
> | `docs/uat.md` | Missing | — | Create for existing features |
> | `docs/changelog.md` | Missing | CHANGELOG.md exists (different format) | Adopt or restructure |
> | `docs/decisions/` | Missing | — | Create retroactive ADRs |
> | `docs/plans/` | Missing | — | Create for future work |
> | `docs/deployment/` | Missing | Deploy script exists | Document existing process |
> | `.claude/settings.local.json` | Missing | — | Configure permissions |
> | Test conventions | Fine | Vitest, co-located, good coverage | No changes needed |
> | Code quality | Fine | ESLint + Prettier configured | No changes needed |
> | Commit conventions | Needs work | Inconsistent messages | Agree convention, document in CLAUDE.md |

Ask the user:

> "Here's how the project maps against the framework. Some things are already in good shape, some need reorganising, and some need creating. Before I create the adoption plan, any of these you want to skip or prioritise?"

## Step 2.5: Ways of Working

Before creating the adoption plan, ask a few quick questions about how the user likes to work. These preferences shape how all framework skills behave — from plan presentation to git workflow to explanation depth.

> "A few quick questions about how you like to work — this helps me adapt across all the skills."

### Returning user detection

First, check whether `~/.claude/CLAUDE.md` already exists (from a previous project using the framework). If it does, read it and summarise the existing per-user preferences:

> "I have your preferences from previous projects — [summary of technical level and communication style]. Still accurate, or want to change anything?"

If accurate, skip to the per-project questions (3 and 4 below). If the user wants to change anything, walk through the relevant per-user questions again.

### Per-user preferences

These follow the user across all projects and are stored in `~/.claude/CLAUDE.md`. **Skip these if the file already exists and the user confirms the preferences are still accurate.**

**Question 1: Technical experience level**

> "How technical are you? I ask because it changes how I explain things — a developer gets terminal commands and code references; someone less technical gets step-by-step walkthroughs. Are you a regular coder, technical but not coding daily, or more on the product/business side?"

Options:
- **Developer** — writes code regularly, comfortable with terminal, git, and debugging
- **Technical but not coding daily** — understands code, can read and edit it, but doesn't write it day-to-day
- **Non-technical** — focuses on product/business, needs clear plain-language explanations

Default if skipped: **Developer**.

**Question 2: Communication verbosity**

> "When I present plans and updates, do you want the full detail or just the headlines? You can always ask for more."

Options:
- **Detailed** — show everything: full task lists, reasoning, alternatives considered
- **Concise** — headlines and key decisions only, I'll ask if I want more detail

Default if skipped: **Detailed**.

### Per-project preferences

These are written directly into the project's `CLAUDE.md` during Step 4 (when CLAUDE.md is created as part of adoption).

**Question 3: Collaboration style**

> "For this project, how hands-on do you want to be? Some people like to review every plan before I start building. Others prefer I just get on with it and show the result."

Options:
- **Collaborative** — review plans before implementation, approve changes, see reasoning
- **Delegative** — trust the plan, show results, flag blockers

Default if skipped: **Collaborative**.

**Question 4: Git workflow**

> "Git workflow — do you want feature branches for every change, or is committing straight to main fine for this project? Will anyone else be working on this with you?"

Options:
- **Branches** — feature branches, merge when done
- **Direct to main** — commit directly to main, simpler workflow

Note solo/team alongside the git workflow preference.

Default if skipped: **Branches**.

### Storing the preferences

1. **Per-user preferences** (technical level, communication verbosity): Write to `~/.claude/CLAUDE.md`. If the file already exists, update the `# User Preferences` section. If it doesn't exist, create it:

```markdown
# User Preferences

- **Technical level:** [Developer / Technical but not coding daily / Non-technical] — [brief description]
- **Communication:** [Detailed / Concise] — [brief description]
```

2. **Per-project preferences** (collaboration style, git workflow, solo/team): Include in the `## Ways of Working` section of the project's `CLAUDE.md` when creating it in Step 4.

### Guidelines

- Ask ONE question at a time
- Keep it quick — 2-4 minutes total
- If the user doesn't care ("whatever you think"), use the default and move on

## Step 3: Create the adoption plan

Based on the mapping and user's goals, create a phased adoption plan. Write it to `docs/plans/framework-adoption.md`.

### Adoption plan structure

```markdown
# Framework Adoption Plan

**Project:** [Name]
**Date:** [Current date]
**Status:** In Progress

---

## Scope

[What the user wants — full framework or selected parts]
[What's being preserved vs created vs reorganised]

## Phase 1: Foundation (do first)

These are the core artifacts that everything else depends on.

### 1.1 Create CLAUDE.md
- [ ] Capture existing conventions from [linter config, existing docs, codebase patterns]
- [ ] Document project structure, commands, and key files
- [ ] Establish any missing conventions (commit style, naming, etc.)

### 1.2 Scaffold docs structure
- [ ] Create `docs/` directory structure
- [ ] Copy framework process to `docs/process.md`
- [ ] Move/reorganise existing documentation into framework locations

### 1.3 Create master plan (retroactive)
- [ ] Extract product definition from [README, existing docs, codebase]
- [ ] Fill gaps conversationally with user
- [ ] Write to `docs/definition/master-plan.md`

### 1.4 Create stack reference
- [ ] Generate from existing project config and dependencies
- [ ] Write to `docs/definition/stack.md`

## Phase 2: History capture

Capture the project's existing decisions and history.

### 2.1 Create retroactive ADRs
- [ ] Identify key technical decisions already made
- [ ] Write ADRs for each: [list specific decisions]
- [ ] Create ADR template at `docs/decisions/_template.md`

### 2.2 Create changelog (retroactive)
- [ ] [Generate from git history / adopt existing changelog]
- [ ] Write to `docs/changelog.md`

## Phase 3: Planning artifacts

Create forward-looking planning documents.

### 3.1 Create implementation plan
- [ ] Mark existing features as completed phases
- [ ] Define future phases from backlog/roadmap
- [ ] Write to `docs/definition/implementation-plan.md`

### 3.2 Create task list
- [ ] Import open items from [GitHub Issues / TODO comments / user input]
- [ ] Organise by phase/area
- [ ] Write to `docs/tasks.md`

## Phase 4: Design documentation (if frontend)

### 4.1 Create design guidelines
- [ ] Extract design tokens from [Tailwind config / CSS variables / existing styles]
- [ ] Document component patterns from existing UI
- [ ] Write to `docs/definition/design-guidelines.md`

### 4.2 Create design system showcase
- [ ] Build from existing components and tokens
- [ ] Write to `docs/definition/design-system.html`

## Phase 5: Operations

### 5.1 Create UAT scenarios
- [ ] Write scenarios for existing features
- [ ] Write to `docs/uat.md`

### 5.2 Document deployment
- [ ] Capture existing deployment process
- [ ] Write to `docs/deployment/first-time-setup.md`
- [ ] Create deploy skill at `.claude/skills/deploy-[project]/SKILL.md`

### 5.3 Configure Claude Code permissions
- [ ] Create `.claude/settings.local.json`
```

### Planning principles

- **Phase 1 is non-negotiable** — CLAUDE.md and the docs structure are the minimum viable adoption
- **Other phases are optional** — based on the user's goals and project needs
- **Preserve existing work** — reorganise and reference, don't delete or rewrite what's already good
- **Retroactive artifacts should reflect reality** — the master plan describes what IS built, not a hypothetical. The implementation plan marks existing features as done.
- **Skip what doesn't apply** — no frontend = no design guidelines. No deployment = no deploy skill. CLI tool = no UAT scenarios for UI.

Present the plan for approval:

> **Adoption plan written to `docs/plans/framework-adoption.md`.**
>
> **[Count] phases:**
> - Phase 1: Foundation — CLAUDE.md, docs structure, master plan, stack reference
> - Phase 2: History capture — retroactive ADRs, changelog
> - Phase 3: Planning — implementation plan, task list
> - Phase 4: Design documentation — [if applicable]
> - Phase 5: Operations — UAT, deployment docs, deploy skill
>
> **Phases I'd skip for this project:** [list any and why]
>
> Want me to proceed with Phase 1, or adjust the plan first?

Wait for approval before proceeding.

## Step 4: Execute the adoption plan

Work through the adoption plan phase by phase. For each artifact you create:

### Creating CLAUDE.md

This is the most important artifact. Build it from:

1. **Existing linter/formatter config** — extract rules and conventions
2. **Existing project structure** — document the actual directory layout
3. **Existing scripts** — document dev, test, lint, build commands
4. **Codebase patterns** — identify naming conventions, API patterns, error handling approaches from the actual code
5. **Conversation with user** — fill gaps for anything not discoverable from the codebase

Follow the same structure as the `/cto` skill would produce (including a **Workflow** section referencing `docs/process.md` and suggesting `/status` when the user is unsure what to do next), but derived from what exists rather than decided from scratch. If conventions are inconsistent or missing, discuss with the user and agree on the standard going forward.

Include a `## Ways of Working` section with the per-project preferences gathered in Step 2.5 (collaboration style, git workflow, solo/team, and testing depth if discussed). Format:

```markdown
## Ways of Working

- **Collaboration style:** [Collaborative / Delegative] — [brief description]
- **Git workflow:** [Branches / Direct to main] — [brief description]
- **Team:** [Solo / Team of N]
- **Testing depth:** [Comprehensive / Practical / Minimal] — [brief description]
```

### Creating the master plan (retroactive)

This is different from `/start-project` — the product already exists. The master plan should:

- **Describe what IS built**, not what might be built
- **Extract from existing sources** — README, about pages, marketing copy, code comments
- **Fill gaps conversationally** — ask the user about goals, users, features, etc. only where the existing sources don't cover it
- **Include a "Current State" section** — what's live, what's working, what's known to be broken or incomplete
- **Include future plans** — where the product is going next

Ask questions one at a time, as with `/start-project`, but acknowledge what you've already learned from the codebase:

> "From the code, I can see the app has [features X, Y, Z]. The README mentions [goal]. Let me ask about a few things I couldn't determine from the code..."

### Creating the stack reference

Generate this almost entirely from project config files:

- package.json / requirements.txt / go.mod — dependencies
- Config files — framework, ORM, test framework, linter, etc.
- Docker/CI config — infrastructure and deployment
- .env.example — environment dependencies

Present the generated stack doc for review — the user can correct any mischaracterisations.

### Creating retroactive ADRs

Identify key technical decisions from:

- Framework and language choice
- Database and ORM choice
- Authentication approach
- API design patterns
- Hosting and deployment platform
- Any significant architectural patterns visible in the code

Write brief ADRs for each. The "Context" section should note these are retroactive captures. Don't fabricate alternatives that weren't actually considered — if you don't know what was considered, say so or ask.

### Creating the implementation plan (retroactive)

Structure the implementation plan with:

- **Completed phases** — group existing features into logical phases, all marked as done
- **Current phase** — anything actively being worked on
- **Future phases** — from the user's roadmap, backlog, or conversation

This gives the project a clear "you are here" marker and a path forward.

### Creating the task list

Pull from all available sources:

- GitHub/GitLab issues (ask the user or check if gh CLI is available)
- TODO/FIXME/HACK comments in the codebase
- Known bugs the user mentions
- Items from the implementation plan's future phases

### Creating design guidelines (if applicable)

Extract from the existing codebase:

- Tailwind config or CSS custom properties → design tokens
- Existing component patterns → component documentation
- Colour usage across the app → colour system
- Typography in use → type scale
- Spacing patterns → spacing system

Document what IS, not what should be. If the existing design is inconsistent, note the inconsistencies and ask the user which direction to standardise toward.

### Creating the design system showcase (if applicable)

Build the self-contained HTML showcase from the extracted design guidelines, following the same approach as `/designer` but reflecting the existing design rather than creating a new one.

### Creating UAT scenarios

Write scenarios for existing features — things that should work today and need to keep working. This creates a regression safety net.

### Documenting deployment

Capture the existing deployment process, don't redesign it. Document:

- How to deploy (the actual current process)
- Environment variables needed
- Database migration steps
- Post-deploy verification

Create the deploy skill (`.claude/skills/deploy-[project]/SKILL.md`) that automates this process.

### Configuring permissions

Offer the same three-tier permission setup as `/start-project` (Cautious, Balanced, Autonomous). If `.claude/settings.local.json` already exists, merge rather than overwrite.

## Step 5: Verify and summarise

After completing all adoption phases:

1. **Check all framework artifacts exist** — run through the status skill's checklist
2. **Verify CLAUDE.md is accurate** — the conventions match the actual codebase
3. **Verify the master plan matches reality** — it describes what's built
4. **Verify the task list is current** — open items reflect real work to do

Present a summary:

> **Framework adoption complete for [Project Name].**
>
> **Documents created:**
> - `CLAUDE.md` — project conventions for Claude Code
> - `docs/definition/master-plan.md` — product specification (retroactive)
> - `docs/definition/stack.md` — tech stack reference
> - `docs/definition/implementation-plan.md` — [X] completed phases, [Y] future phases
> - `docs/definition/design-guidelines.md` — design system (from existing UI)
> - `docs/tasks.md` — [X] open tasks
> - `docs/uat.md` — [X] scenarios for existing features
> - `docs/changelog.md` — project history
> - `docs/decisions/` — [X] retroactive ADRs
> - `docs/deployment/first-time-setup.md` — deployment guide
> - `.claude/skills/deploy-[project]/SKILL.md` — deploy skill
>
> **Documents preserved/reorganised:**
> - [List any existing docs that were kept or moved]
>
> **What changed about the project:**
> - [Summary of structural changes — new directories, moved files, etc.]
> - [No code was modified — this is documentation only]
>
> **You can now use:**
> - `/status` — check project health
> - `/work` — pick up tasks from the backlog
> - `/implement` — continue with the next implementation phase
> - `/new-issue` — capture bugs and ideas
> - `/deploy-[project]` — deploy changes
> - `/uat` — test existing features

## Guidelines

### Philosophy

- **Retrofit, don't rebuild** — the project exists and works. Your job is to add the framework's documentation and workflow layer on top, not to restructure the codebase.
- **Describe what IS, not what should be** — retroactive documents capture reality. Aspirational changes go in the task list or future phases.
- **Preserve existing conventions** — if the project uses Black and the framework examples show Prettier, use Black. The framework is convention-agnostic.
- **Don't touch application code** — this skill creates documentation and configuration only. No refactoring, no code changes, no dependency additions (unless the user explicitly asks).
- **Respect existing documentation** — if the project has good docs, reorganise them into the framework structure rather than rewriting from scratch. Link to or incorporate existing content.

### Conversation style

- Ask ONE question at a time, as with all framework skills
- Acknowledge what you've learned from the codebase before asking for more
- Don't re-ask what you can already determine from the code
- Be honest about what you couldn't determine and need the user to clarify
- Make recommendations where the project has gaps — "I noticed there's no consistent commit convention. I'd suggest Conventional Commits because [reason]. Sound good?"

### Scaling to project size

- **Small projects** (< 20 files) — the full adoption might take one session. Keep artifacts proportionally brief.
- **Medium projects** (20-100 files) — adoption may take 2-3 sessions. Focus on CLAUDE.md and core docs first.
- **Large projects** (100+ files) — adoption is a multi-session effort. Phase 1 (foundation) is the priority. Other phases can be done incrementally over subsequent sessions.

### What NOT to do

- Do NOT modify application code — this is a documentation and configuration skill
- Do NOT delete existing documentation — reorganise, consolidate, or supplement it
- Do NOT fabricate project history — if you don't know why a decision was made, ask or note it as unknown
- Do NOT assume the project needs everything — skip artifacts that don't apply (no frontend = no design system)
- Do NOT rush the master plan — it's the most important retroactive artifact and worth getting right
- Do NOT ignore existing conventions in favour of framework defaults — the framework adapts to the project, not the other way around
- Do NOT create empty placeholder files — every document should have real content or not exist yet
