---
description: Scaffold project documentation and create the master plan
---

# Start Project

You are helping the user kick off a new project. This skill scaffolds the documentation structure and then walks through an interactive process to create the master plan. You act as a skilled product leader, helping the user articulate their vision and fleshing out details where they are unsure.

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

## Step 1: Scaffold the docs directory

Create the following directory structure and empty markdown files in the project root:

```
docs/
  process.md
  changelog.md
  tasks.md
  uat.md
  definition/
    master-plan.md
    design-guidelines.md
    implementation-plan.md
  decisions/
  plans/
  deployment/
  reference/
```

All markdown files should be created empty (no content yet), **except** `docs/process.md` which should be populated with the process content below. This is the team's standard process document — it tells anyone working on the project (including Claude in future sessions) what the overall workflow is, which skills to use, and what comes next.

Write the following content to `docs/process.md`:

<process-content>
# Claude Code Project Framework

A repeatable process for starting and running projects in [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Use this as the starting point for all new projects, and share with your team so everyone follows the same workflow.

The framework uses [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) — reusable prompt templates that guide Claude through each step with consistent quality. You invoke them by typing `/skill-name` in Claude Code.

## Getting Started

### Prerequisites

- **Claude Code** installed and working. [Get Claude Code here](https://docs.anthropic.com/en/docs/claude-code/overview) — you'll need an Anthropic account with a Max plan, or API access.

### Setup

1. **Clone this repo** into a location on your machine (not inside a project):

   ```bash
   git clone https://github.com/petebulley/claude-code-framework.git ~/claude-code-framework
   ```

2. **Symlink the framework skills into your global Claude skills directory.** This makes them available in every Claude Code session, regardless of which project you're working in:

   ```bash
   mkdir -p ~/.claude/skills
   for skill in ~/claude-code-framework/.claude/skills/*/; do
     ln -sf "$skill" ~/.claude/skills/
   done
   ```

   This creates symlinks in `~/.claude/skills/` pointing back to the cloned repo, so the skills stay git-tracked and updatable.

3. **Start a new project.** Create your project directory, open Claude Code, and type:

   ```
   /start-project
   ```

   The skill will scaffold your documentation, walk you through creating the master plan, and configure Claude's permissions. From there, follow the steps below in order.

   **Existing project?** If you already have a project and want to bring it into the framework, use:

   ```
   /adopt
   ```

   This will audit your project, map what exists against the framework, and create a plan to fill the gaps — preserving your existing code and conventions.

### Recommended: Playwright MCP

For visual verification during design and implementation, set up the Playwright MCP:

```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```

This lets Claude open pages in a real browser, take screenshots, and verify UI work. The `/designer` skill will prompt you to set this up, but you can do it in advance.

### Updating the Framework

Since you cloned the repo, you can pull updates at any time:

```bash
cd ~/claude-code-framework && git pull
```

Updated skills are available immediately in your next Claude Code session — no reconfiguration needed.

---

## Overview

**Steps 1-6** take you from idea to deployed, tested product. Run them in order for the initial build. **Step 7** is your ongoing development workflow — use it for all work after the initial build is complete. **Already have a project?** Use `/adopt` to retrofit the framework — see [Adopting the Framework for Existing Projects](#adopting-the-framework-for-existing-projects).

| Step | Name | Skill | Output |
|------|------|-------|--------|
| 1 | Start Project | `/start-project` | Project docs scaffold, master plan, Claude permissions |
| 2 | CTO | `/cto` | Tech stack, implementation plan, conventions, CLAUDE.md |
| 3 | Designer | `/designer` | Design guidelines, design system showcase |
| 4 | Implement | `/implement` | Working code, tests, documentation per phase |
| 5 | First Deploy | `/first-deploy` | First-time deployment guide, project deploy skill |
| 6 | UAT | `/uat` | Test results, issue log, sign-off |
| 7 | Work | `/work` | Bug fixes, features, tweaks, refactors |

---

## Step 1: Start Project

Scaffold the project documentation and create the master plan.

**Skill:** `/start-project`
**When:** Beginning of every new project.

### What happens
1. Scaffold the `/docs` directory structure with empty files and sub-directories
2. Prompt the user to add any existing documentation or references to `docs/reference/`
3. Walk through an interactive process to define and document the master plan
4. Configure Claude Code permissions based on user's risk appetite (`.claude/settings.local.json`)

### What gets created

```
docs/
  process.md
  changelog.md
  tasks.md
  uat.md
  definition/
    master-plan.md
    design-guidelines.md
    implementation-plan.md
  decisions/
  plans/
  deployment/
  reference/
```

---

## Step 2: CTO

Agree technology choices, establish conventions, and create the implementation plan. This step is about decisions and documentation only — no code is written.

**Skill:** `/cto`
**When:** After the master plan is agreed in Step 1.

### What happens
1. Review the master plan and understand technical requirements
2. Choose the tech stack (language, framework, database, hosting, etc.), considering existing infrastructure
3. Choose testing framework and establish testing methodology (TDD/red-green-refactor as default)
4. Choose code quality tooling (linter, formatter, git hooks, commit conventions)
5. Establish project conventions (structure, naming, API design, database patterns, error handling)
6. Establish documentation principles (ADRs, plans in `/docs/plans`, changelog, living docs)
7. Create the phased implementation plan with dependencies, risks, and MVP definition
8. Generate `CLAUDE.md` codifying all conventions for future Claude sessions

### What gets created
- `docs/definition/implementation-plan.md` — phased build plan
- `docs/definition/stack.md` — full tech stack reference
- `docs/decisions/_template.md` — ADR template
- `docs/decisions/001-documentation-first.md` — documentation principles ADR
- `CLAUDE.md` — project conventions for Claude Code

---

## Step 3: Designer

Agree design direction and create the design system. The user is encouraged to share design inspiration (websites, screenshots, mood words) to guide the process.

**Skill:** `/designer`
**When:** After tech choices are agreed in Step 2.

### What happens
1. Gather design inspiration and references from the user
2. Establish design philosophy and core visual direction
3. Create HTML showcase pages in `docs/` with multiple options for each design decision (colour palette, typography, icons, components, layouts, motion) — the user opens these to compare options and give feedback
4. Iterate on each showcase until the user locks in their choice
5. Write the design guidelines document
6. Build a final consolidated design system showcase (single-page HTML)
7. Iterate with the user until they're happy with the design

### What gets created
- `docs/showcase-*.html` — decision showcase pages with multiple options (colour palette, typography, icons, components, layouts)
- `docs/definition/design-guidelines.md` — full design system specification
- `docs/definition/design-system.html` — live interactive showcase of all agreed design elements

---

## Step 4: Implement

Build the project one phase at a time. Each invocation of `/implement` works on a single phase — planning it, implementing it, testing it, and documenting it.

**Skill:** `/implement`
**When:** After design is agreed in Step 3. Run once per phase, repeatedly, until all phases are complete.

### What happens
1. Show overall progress and identify the next phase to implement
2. Read all documentation and understand the current codebase
3. Create a detailed plan for the phase (stored in `/docs/plans`)
4. Present the plan for user review and approval
5. Add approved tasks to `docs/tasks.md` (the master task list)
6. Implement the phase: code, tests, and documentation together
7. Keep `docs/tasks.md` updated in real-time as tasks are completed
8. Record any technical decisions as ADRs in `docs/decisions/`
9. Write UAT scenarios for the phase in `docs/uat.md`
10. Present local testing guide so the user can verify the phase
11. Update changelog, implementation plan status, and CLAUDE.md at phase completion

### What gets created
- `docs/plans/phase-[N]-[name].md` — detailed phase plan
- Application code and tests for the phase
- ADRs in `docs/decisions/` for any technical decisions made
- Updated `docs/tasks.md` with task progress
- Updated `docs/uat.md` with UAT scenarios for the phase
- Updated `docs/changelog.md` with phase summary

---

## Step 5: First Deploy

Set up first-time deployment to production and create a project-specific deploy skill for ongoing use.

**Skill:** `/first-deploy`
**When:** After the first implementable phase is complete.

### What happens
1. Read project documentation to understand the deployment landscape (hosting, database, services, env vars)
2. Ask the user about accounts, domains, and manual setup requirements
3. Create a comprehensive first-time deployment guide with every step spelled out
4. Create a project-specific `/deploy-[project]` skill for all future deployments
5. Present both documents for review

### What gets created
- `docs/deployment/first-time-setup.md` — step-by-step first-time deployment guide
- `.claude/skills/deploy-[project]/SKILL.md` — ongoing deployment skill (invoked as `/deploy-[project]`)

---

## Step 6: UAT

User acceptance testing of the deployed project. The test scenarios were written during each `/implement` phase and live in `docs/uat.md`.

**Skill:** `/uat`
**When:** After deployment to production. Can be re-run after significant changes.

### What happens
1. Show UAT progress summary (passed/failed/not started counts)
2. Find the next uncompleted test
3. Prepare the test environment (browser state, accounts, device, prerequisites)
4. Walk through test steps one at a time with explicit, detailed instructions
5. If an issue is found: investigate, fix, deploy via `/deploy-[project]`, and retest from the beginning
6. Mark tests as passed or failed in `docs/uat.md`
7. Continue to the next test or stop — progress is saved

### What gets created
- Updated `docs/uat.md` with test results (pass/fail status, failure notes)

---

## Step 7: Work

Ongoing development — bug fixes, new features, tweaks, and refactors. This is the skill used for all work after the initial build is complete.

**Skill:** `/work`
**When:** Ongoing, after initial build and UAT. This is the day-to-day development skill.

### What happens
1. Ask the user: pick from the task list or work on something new?
2. If task list: show open tasks, failed UAT tests, and blocked items
3. If new: classify the work (bug fix, feature, tweak, refactor)
4. Read relevant code, conventions, and design guidelines
5. Plan (scaled to work size — full plan for features, diagnosis for bugs, brief statement for tweaks)
6. Implement using red-green-refactor: failing tests first, then code
7. Verify (test suite, lint, type checks, build)
8. Update documentation (tasks.md, changelog, UAT scenarios for new features, ADRs for decisions)
9. Suggest deploying via `/deploy-[project]`

### What gets created
- `docs/plans/feature-[name].md` — plan for new features (not for bugs/tweaks)
- Updated application code and tests
- Updated `docs/tasks.md` with task status
- Updated `docs/changelog.md` with change summary
- Updated `docs/uat.md` with UAT scenarios (for new user-facing features)
- ADRs in `docs/decisions/` (for non-trivial decisions)

---

## Adopting the Framework for Existing Projects

Already have a project? Use `/adopt` to bring it into the framework without starting from scratch.

**Skill:** `/adopt`
**When:** You have an existing project with code, possibly some documentation, and want to use the framework's workflow and skills going forward.

### What happens

1. **Audit** — explores the project thoroughly: code, docs, conventions, tests, deployment, project maturity
2. **Map** — compares what exists against every framework artifact in a clear table, categorised as: fine (no changes needed), needs reorganising (content exists but in wrong place/format), or missing (needs creating)
3. **Plan** — writes a phased adoption plan to `docs/plans/framework-adoption.md`:
   - Phase 1: Foundation — `CLAUDE.md`, `docs/` structure, retroactive master plan, stack reference
   - Phase 2: History capture — retroactive ADRs for key decisions already made, changelog from git history
   - Phase 3: Planning — implementation plan (existing features as completed phases, future work as upcoming phases), task list from issues/TODOs
   - Phase 4: Design documentation — design guidelines and showcase extracted from existing UI (skipped if no frontend)
   - Phase 5: Operations — UAT scenarios for existing features, deployment docs, deploy skill
4. **Execute** — works through the plan conversationally, creating each artifact from the existing codebase rather than from a blank slate
5. **Verify** — confirms everything's in place, then hands off to the normal workflow

### Key principles

- **No code changes** — only documentation and configuration are created. Your application code is untouched.
- **Preserves existing conventions** — if your project uses Black, the framework uses Black. It adapts to your project, not the other way around.
- **Retroactive docs reflect reality** — the master plan describes what IS built, not a hypothetical. The implementation plan marks existing features as done.
- **Skip what doesn't apply** — no frontend means no design system. CLI tool means no UI-focused UAT scenarios.
- **Phases are optional** — Phase 1 (foundation) is the minimum. The rest depends on your goals.

### What gets created

- `CLAUDE.md` — project conventions derived from existing code and config
- `docs/definition/master-plan.md` — product specification (retroactive, from README and codebase)
- `docs/definition/stack.md` — tech stack reference (generated from project config)
- `docs/definition/implementation-plan.md` — completed phases for existing features, future phases for planned work
- `docs/definition/design-guidelines.md` — design system extracted from existing UI (if frontend)
- `docs/definition/design-system.html` — interactive showcase (if frontend)
- `docs/tasks.md` — task list from issues, TODOs, and planned work
- `docs/uat.md` — UAT scenarios for existing features
- `docs/changelog.md` — project history from git log
- `docs/decisions/` — retroactive ADRs for key technical decisions
- `docs/deployment/first-time-setup.md` — existing deployment process documented
- `.claude/skills/deploy-[project]/SKILL.md` — deploy skill for ongoing use
- `.claude/settings.local.json` — Claude Code permissions

After adoption, you can use all the ongoing skills: `/work`, `/status`, `/new-issue`, `/implement`, `/uat`, and `/deploy-[project]`.

---

## Utility Skills

Skills used throughout the project lifecycle, not tied to a specific step.

| Skill | Description |
|-------|-------------|
| `/new-issue` | Quickly capture a bug, feature idea, or improvement to `docs/tasks.md` without breaking your current flow. Designed for speed — log it and get back to work. |
| `/status` | Check where the project stands — implementation progress, open tasks, UAT results, recent activity — and get a recommendation for what to do next. |

---

## Feedback and Contributing

This framework is open source and actively improved based on real-world usage. If you've used it to build a project, I'd love to hear how it went.

- **Share feedback** — [Open an issue](https://github.com/petebulley/claude-code-framework/issues) with your experience, suggestions, or questions
- **Report a problem** — if a skill didn't work well or produced poor results, [open an issue](https://github.com/petebulley/claude-code-framework/issues) describing what happened
- **Suggest improvements** — [open a pull request](https://github.com/petebulley/claude-code-framework/pulls) with your proposed changes

The most useful feedback is specific: which skill, what happened, what you expected, and what would have been better.
</process-content>

After creating the structure, confirm to the user and prompt them to add any existing reference material:

> Project docs scaffolded. Ready to work on the master plan.
>
> **Before we start:** if you have any existing documentation, references, or background material for this project — specs, briefs, wireframes, research, competitor analysis, API docs, brand guidelines, or anything else that provides context — drop them into `docs/reference/`. I'll use them to inform the master plan conversation, so the more context I have, the better the outcome.

Wait for the user to confirm they've added files (or have none to add). If they add files, read everything in `docs/reference/` before proceeding to Step 2 so you can incorporate the context throughout the master plan conversation.

## Step 2: Create the master plan

Walk the user through defining their project by exploring the areas below. Ask questions **one at a time**, conversationally. Listen to each answer before moving on. Where the user is unsure or vague, use your product expertise to suggest options, probe deeper, and help them think through the implications.

You do not need to rigidly follow the order below. Let the conversation flow naturally. Some projects won't need every section (e.g. a CLI tool won't have a marketing homepage). Skip or adapt sections as appropriate. The goal is to capture enough detail that a developer could build from this document.

### 2.1 Overview

Start here. Understand what the project is and why it exists.

Questions to explore:
- "What are you building? Give me the one-liner."
- "What problem does this solve? Who has this problem today?"
- "What's your vision for the finished product?"
- "What are the explicit goals for v1?"
- "What is explicitly out of scope for v1?" (Non-goals are just as important as goals)

Capture this as:
- **Overview** paragraph describing the product
- **Problem Statement** section
- **Goals** as a bulleted list
- **Non-Goals (v1)** as a bulleted list

### 2.2 Users and Roles

Understand who uses the product and what they can do.

Questions to explore:
- "Who are the different types of users?"
- "What can each type of user do?"
- "Are there admin or elevated roles? What extra capabilities do they have?"
- "How do users get into the system? (sign-up, invite, SSO, etc.)"

Capture as a **Users & Roles** section with a subsection per role describing their capabilities.

### 2.3 Core Concepts

Identify the key domain objects and how they relate.

Questions to explore:
- "What are the main things (objects/entities) in your system?"
- "How do they relate to each other?"
- "What properties does each one have?"

Capture as a **Core Concepts** section with a subsection per concept listing its properties and relationships.

### 2.4 Features

This is typically the largest section. Work through each feature area the user describes.

Questions to explore:
- "Walk me through the main user flows. What does a user do first? Then what?"
- "What are the key screens or views?"
- "How does [feature X] work in detail?"
- For each feature, probe: "What happens when...?" / "What if the user...?" / "How should this behave on mobile?"

Where the user gives a high-level description, help them think through edge cases, error states, and the detailed behaviour. Suggest approaches based on common patterns.

Capture as a **Feature Specification** section with numbered subsections per feature area.

### 2.5 Permissions and Access

If the product has multiple roles or sensitive data, clarify who can see and do what.

Questions to explore:
- "Who can see what? Are there any privacy constraints?"
- "Can users see each other's data?"
- "What can admins see vs regular users?"

Capture as a **Permissions Model** section. A table format works well (content vs role vs access level).

### 2.6 Integrations

If the product integrates with external services.

Questions to explore:
- "Does this integrate with any external services? (Slack, email, calendar, payment, etc.)"
- "What does each integration do? What triggers it?"
- "What notifications does the system send, through which channels, and when?"

Capture integrations as their own subsections. If there are many notifications, include a **Notifications Summary** table.

### 2.7 Architecture and Infrastructure

Capture any technical preferences or constraints the user already has in mind. This will be expanded in Step 2 (CTO) of the process, so keep it high-level here.

Questions to explore:
- "Do you have any technology preferences or constraints?"
- "Any thoughts on hosting, database, or infrastructure?"
- "Is this multi-tenant? What's the data isolation model?"
- "Any requirements for backups, disaster recovery, or compliance?"

Capture as a **Technical Architecture** section with subsections as needed (Stack, Data Model, Integrations, Backup & DR).

### 2.8 Business Model (if applicable)

For products with commercial aspects.

Questions to explore:
- "How will this make money? What's the pricing model?"
- "Is there a free tier or trial?"
- "What's the sign-up / onboarding flow?"
- "Any growth or viral mechanics?"

Capture as a section within the document (e.g. **Multi-Tenant Architecture & Billing** or **Pricing**).

### 2.9 Success Metrics

How will you know the project is successful?

Questions to explore:
- "What does success look like for this project?"
- "What metrics would you track?"
- "Any specific targets for v1?"

Capture as a **Success Metrics** section with product, business, and engagement metrics as appropriate.

### 2.10 Future Considerations

What's been deliberately deferred but should be noted.

Questions to explore:
- "What are you thinking about for post-v1?"
- "Anything you've deliberately deferred that we should note for later?"

Capture as a **Future Considerations (Post-v1)** bulleted list.

### 2.11 Testability

Review what was captured in sections 2.2 (Users & Roles), 2.4 (Features), and 2.6 (Integrations) and proactively raise testability concerns. Less experienced builders often don't think about how they'll test from different perspectives until it's too late — surface these now so the right mechanisms get built.

**Multiple user roles** — If the project has more than one role (e.g. admin and user, or manager and team member), the builder will need a way to test each role's experience. Ask: "You have [N] user roles. When it comes to testing, you'll need to experience the app as each role. We should plan for test accounts — one per role — so you can verify each experience. Does that make sense, or do you have another approach in mind?"

**Scheduled or automated features** — If any features run on schedules or are triggered automatically (notifications, digests, reports, cron jobs, webhook responses), the builder won't be able to test these by waiting. Ask: "Some features run automatically — [list them]. We should build a way to trigger each one manually so you can test them on demand. For example, an admin button or API endpoint that fires the [notification/digest/report] immediately. Worth planning for?"

**External service integrations** — If the project integrates with external services (Slack, email, payment providers, SMS, etc.), the builder needs sandbox or test modes to verify without affecting real users. Ask: "You're integrating with [services]. We should plan for test/sandbox modes so you can verify these work without sending real messages, charging real cards, etc. Most services offer test modes — we'll configure those during implementation."

Capture answers in a **Testability** section of the master plan. Keep it brief — just document which mechanisms are needed (test accounts, manual triggers, sandbox modes) and any preferences the user expressed.

If the project has none of these (single role, no automated features, no external integrations), skip this section entirely.

## Step 2.5: Ways of Working

After the master plan conversation, ask a few quick questions about how the user likes to work. These preferences shape how all framework skills behave — from plan presentation to git workflow to explanation depth.

> "Great, I have a solid picture of the project. Before we configure Claude's permissions, a few quick questions about how you like to work — this helps me adapt across all the skills."

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

This affects explanation depth across `/implement`, `/uat`, `/cto`, `/work`, `/first-deploy`, and `/status`.

**Question 2: Communication verbosity**

> "When I present plans and updates, do you want the full detail or just the headlines? You can always ask for more."

Options:
- **Detailed** — show everything: full task lists, reasoning, alternatives considered
- **Concise** — headlines and key decisions only, I'll ask if I want more detail

Default if skipped: **Detailed**.

This affects plan presentations, summaries, and status reports across all skills.

### Per-project preferences

These may differ between projects and are carried forward to the `/cto` skill, which writes them into the project's `CLAUDE.md` under a `## Ways of Working` section.

**Question 3: Collaboration style**

> "For this project, how hands-on do you want to be? Some people like to review every plan before I start building. Others prefer I just get on with it and show the result."

Options:
- **Collaborative** — review plans before implementation, approve changes, see reasoning
- **Delegative** — trust the plan, show results, flag blockers

Default if skipped: **Collaborative**.

This affects approval gates in `/implement`, `/work`, `/cto`, and `/designer`.

**Question 4: Git workflow**

> "Git workflow — do you want feature branches for every change, or is committing straight to main fine for this project? Will anyone else be working on this with you?"

Options:
- **Branches** — feature branches, merge when done. Best for teams or projects where you want to review before merging.
- **Direct to main** — commit directly to main. Simpler workflow, good for solo projects.

The "anyone else" follow-up captures whether this is solo or team work. Note this alongside the git workflow preference — it affects whether commit messages and PR descriptions need to explain context to others.

Default if skipped: **Branches**.

This affects worktree usage in `/work` and `/implement`, and the deploy skill template in `/first-deploy`.

### Storing the preferences

After gathering the answers:

1. **Per-user preferences** (technical level, communication verbosity): Write to `~/.claude/CLAUDE.md`. If the file already exists, update the `# User Preferences` section. If it doesn't exist, create it with this format:

```markdown
# User Preferences

- **Technical level:** [Developer / Technical but not coding daily / Non-technical] — [brief description]
- **Communication:** [Detailed / Concise] — [brief description]
```

2. **Per-project preferences** (collaboration style, git workflow, solo/team): Note these for the `/cto` skill to include in the project's `CLAUDE.md` when it generates it. Summarise them to the user:

> "Got it. I'll carry these preferences forward — the `/cto` skill will include them in your project's `CLAUDE.md` so every skill picks them up automatically."

### Guidelines

- Ask ONE question at a time, as with all framework conversations
- Keep it quick — this should take 2-4 minutes (2 questions if returning user, 4 if new)
- Don't over-explain the options. Present them naturally and move on.
- If the user doesn't care about a preference ("whatever you think"), use the default and move on

## Step 3: Configure Claude Code permissions

After the master plan conversation is complete (or as a natural break point), ask the user about their risk appetite for the project. This configures `.claude/settings.local.json` so Claude can work with fewer permission prompts.

Ask the user:

> "Before we write up the master plan, let's configure Claude's permissions for this project so you're not constantly approving routine actions. How hands-off do you want Claude to be?"

Use AskUserQuestion with these options:
- **Cautious** — Claude asks before running most commands. Good for production systems or sensitive projects.
- **Balanced** — Claude can read, write, and run common dev commands (install, test, lint, build, dev servers) without asking. Asks before git operations, deployments, or anything destructive.
- **Autonomous** — Claude can do almost everything without asking, including git commits and running any project scripts. Only asks before pushing to remote or destructive operations.

Based on the selection, propose the settings to the user before writing them. Show exactly what will be allowed:

### Cautious

```json
{
  "permissions": {
    "allow": [
      "Bash(cat *)",
      "Bash(ls *)"
    ]
  }
}
```

Minimal auto-approvals. Claude will prompt for most actions.

### Balanced

```json
{
  "permissions": {
    "allow": [
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(npm install *)",
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(bun *)",
      "Bash(pnpm *)",
      "Bash(yarn *)",
      "Bash(node *)",
      "Bash(python *)",
      "Bash(pip install *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(touch *)",
      "Bash(chmod *)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git branch*)",
      "Bash(git show*)",
      "Bash(git stash*)"
    ]
  }
}
```

Claude can run dev tooling and read git state without asking. Will still prompt for git writes (commit, push, checkout), file deletion, and anything outside the allow list.

### Autonomous

```json
{
  "permissions": {
    "allow": [
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(npm install *)",
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(bun *)",
      "Bash(pnpm *)",
      "Bash(yarn *)",
      "Bash(node *)",
      "Bash(python *)",
      "Bash(pip install *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(touch *)",
      "Bash(chmod *)",
      "Bash(rm *)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git branch*)",
      "Bash(git show*)",
      "Bash(git stash*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git switch *)",
      "Bash(git merge *)",
      "Bash(git rebase *)",
      "Bash(git fetch *)",
      "Bash(git pull *)"
    ]
  }
}
```

Claude can do almost everything locally without asking. Will still prompt for `git push`, `git reset --hard`, and other remote/destructive operations.

### Applying the settings

After showing the proposed settings, ask:

> "Here's what I'd set for [level]. Claude will be able to [summary of what's allowed] without asking. Anything outside this list still requires your approval. Happy with these?"

If the user confirms, write the settings to `.claude/settings.local.json`. If the file already exists, read it first and merge the permissions (don't overwrite other settings).

If the user wants to adjust specific permissions, accommodate their changes before writing.

## Step 4: Write the master plan

After working through the conversation, compile everything into `docs/definition/master-plan.md`.

The document should follow this structure (omit sections that don't apply):

```markdown
# [Project Name] — Master Plan

**[Tagline or one-liner]**

**Version:** 1.0
**Author:** [User name]
**Date:** [Current date]
**Status:** Draft

---

## 1. Overview
### 1.1 Problem Statement
### 1.2 Goals
### 1.3 Non-Goals (v1)

## 2. Users & Roles

## 3. Core Concepts

## 4. Feature Specification

## 5. Permissions Model

## 6. [Integration-specific sections]

## 7. Technical Architecture

## 8. Testability

## 9. [Business Model / Pricing — if applicable]

## 10. Success Metrics

## 11. Future Considerations (Post-v1)
```

After writing the document, present a summary to the user:

> Master plan written to `docs/definition/master-plan.md`.
>
> **Sections covered:** [list sections]
> **Key decisions captured:** [list any important decisions made during the conversation]
> **Open questions:** [list anything still unresolved]
>
> Review the document and let me know if you'd like to adjust anything. When you're happy, we'll move on to the `/cto` skill — choosing the tech stack and creating the implementation plan.

## Guidelines

### Conversation style
- Ask ONE question at a time. Do not overwhelm with multiple questions.
- Listen to the full answer before asking the next question.
- Probe deeper where answers are vague: "Can you give me an example?" / "What would that look like in practice?" / "What happens if...?"
- Summarise what you've heard after each major area: "So for users, I'm hearing [summary]. Does that capture it?"
- Suggest and recommend where the user is unsure. You are a product leader, not just a scribe.
- Call out gaps or potential issues: "One thing worth considering is..." / "Most products like this also need..."

### Writing style
- Clear, professional, specific
- Use concrete language, not vague aspirations
- Include enough detail that a developer could build from this document
- Use tables where they make content clearer (permissions, notifications)
- Use code blocks for data models and directory structures
- British English spelling

### What NOT to do
- Do not ask all the questions at once
- Do not write the document until you've gathered enough information
- Do not skip the non-goals — they prevent scope creep later
- Do not include technology decisions that belong in the CTO step (Step 2), unless the user has strong preferences to capture now
