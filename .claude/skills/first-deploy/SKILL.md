---
description: Set up first-time deployment to production and create a project-specific deploy skill for ongoing use
---

# First Deploy

This skill does two things:

1. **First-time deployment guide** — creates a detailed step-by-step document for the user to follow to get the project deployed to production for the first time.
2. **Project-specific deploy skill** — creates a `/deploy-[project]` skill in the project's `.claude/skills/` directory that handles every subsequent deployment.

You do NOT deploy the project yourself — you create the documentation and automation so the user (and Claude in future sessions) can deploy reliably every time.

**Prerequisites:**
- At least one implementation phase must be complete (something to deploy)
- `docs/definition/stack.md` must exist (to know the hosting platform, database, and services)
- `docs/definition/implementation-plan.md` must exist (to understand the deployment pipeline design)
- `CLAUDE.md` must exist (to know project conventions, commands, and structure)

## Step 1: Understand the deployment landscape

Read the project documentation to understand:
- **Hosting platform** — where the app will be deployed (Railway, Vercel, AWS, PythonAnywhere, etc.)
- **Database** — what database is used and where it's hosted
- **External services** — what third-party services need configuration (OAuth providers, Slack apps, email providers, payment providers, etc.)
- **Environment variables** — read `.env.example` or equivalent to catalogue all required env vars
- **Build process** — how the app is built and what commands are needed
- **Database migrations** — how migrations are managed and applied
- **Background services** — any separate services that need deploying (WebSocket servers, workers, cron jobs)
- **Domain/DNS** — any domain configuration needed
- **CI/CD** — whether there's a CI pipeline or it's push-to-deploy

Ask the user:
> "I've read through the stack and implementation plan. Before I create the deployment guide, a few questions:"

Probe for anything not covered in the docs:
- "Have you already created accounts on [hosting platform]? Or do we need to set those up?"
- "Do you have a domain name for this project?"
- "Are there any services that need manual setup first? (e.g. Google Cloud project for OAuth, Slack app configuration)"
- "Is there a GitHub repository set up, or do we need to create one?"

## Step 2: Create the first-time deployment guide

Write a comprehensive, step-by-step guide to `docs/deployment/first-time-setup.md`.

This document should be **extremely detailed** — written so that someone unfamiliar with the hosting platform could follow it without getting stuck. Every click, every command, every configuration field.

### Guide structure

```markdown
# [Project Name] — First-Time Production Deployment

**Date:** [Current date]
**Hosting:** [Platform]
**Database:** [Provider]
**Domain:** [Domain or TBD]

---

## Prerequisites

Before starting, you will need:
- [ ] [Account on hosting platform]
- [ ] [GitHub repository]
- [ ] [Domain name (if applicable)]
- [ ] [External service accounts — list each one]

---

## 1. GitHub Repository Setup

### 1.1 Create the repository
[Step-by-step: create repo, set visibility, add .gitignore]

### 1.2 Initial push
[Commands to initialise git, add remote, push]

### 1.3 Branch protection (optional)
[How to protect main branch if desired]

---

## 2. [Hosting Platform] Setup

### 2.1 Create the project
[Step-by-step with the specific platform]

### 2.2 Connect to GitHub
[How to link the repo for auto-deploy]

### 2.3 Configure environment variables
[List EVERY env var needed, with description and where to get the value]

| Variable | Description | How to get it |
|----------|-------------|---------------|
| `DATABASE_URL` | PostgreSQL connection string | Provided by [platform] when you add PostgreSQL |
| `AUTH_SECRET` | NextAuth session encryption key | Run `openssl rand -base64 32` |
| ... | ... | ... |

### 2.4 Database setup
[How to provision the database, run migrations, seed if needed]

### 2.5 Build and deploy settings
[Build command, start command, health check, any platform-specific config]

---

## 3. External Service Configuration

### 3.1 [Service Name — e.g. Google Cloud / OAuth]
[Step-by-step: create project, enable APIs, create credentials, set redirect URIs]

### 3.2 [Service Name — e.g. Slack App]
[Step-by-step: create app, configure permissions, install to workspace]

### 3.3 [Service Name — e.g. Stripe]
[Step-by-step: create account, get API keys, configure webhooks]

[... one section per external service ...]

---

## 4. Domain & DNS (if applicable)

### 4.1 Add custom domain
[Platform-specific steps]

### 4.2 Configure DNS records
[Exact DNS records to add]

### 4.3 SSL certificate
[Usually automatic — confirm it's working]

---

## 5. Post-Deployment Verification

### 5.1 Health check
[Verify the health endpoint responds]

### 5.2 Database connection
[Verify the app connects to the database]

### 5.3 External services
[Verify OAuth, Slack, email, etc. are working]

### 5.4 First user sign-in
[Walk through the first sign-in flow]

---

## 6. Ongoing Deployment

After first-time setup, deployments are handled by the `/deploy-[project]` skill.
See the skill at `.claude/skills/deploy-[project]/SKILL.md` for the deployment workflow.
```

### Writing principles

- **Every step must be explicit** — don't say "configure your OAuth credentials", say "Navigate to console.cloud.google.com → Create Project → Enter project name → Click Create → Navigate to APIs & Services → Credentials → Create Credentials → OAuth client ID → ..."
- **Include exact commands** — don't say "push to GitHub", say `git remote add origin git@github.com:username/project.git && git push -u origin main`
- **Environment variables table** — list every single env var with a description and instructions on where to get the value
- **Screenshots aren't possible** — compensate with very precise navigation instructions
- **Include verification steps** — after each major section, include how to verify it worked
- **Link to platform docs** — for complex platform-specific steps, include links to the official documentation

Present the guide to the user:

> First-time deployment guide written to `docs/deployment/first-time-setup.md`.
>
> This covers:
> - [List of sections]
> - [Count] environment variables documented
> - [Count] external services to configure
>
> Please review the guide. You'll follow these steps to get to production. Once you've completed the first-time setup, the deploy skill will handle all future deployments.

## Step 3: Create the project-specific deploy skill

Create a deploy skill at `.claude/skills/deploy-[project]/SKILL.md` that handles every subsequent deployment. This skill will be invoked as `/deploy-[project]` in future sessions.

The skill should be tailored to the specific project — its hosting platform, database, migration tool, test commands, and deployment workflow.

### Deploy skill structure

```markdown
---
description: Test, commit, and push [Project Name] changes to deploy via [Platform]
---

# Deploy [Project Name]

You are helping the user deploy changes to [Project Name].
[Brief description of how deployment works — e.g. "deploys automatically from GitHub via Railway"]

## Step 1: Review what's changed

[git status and diff to show what will be deployed]
[Present summary of files changed, untracked files]
[If nothing changed, stop]

## Step 2: Verify database state

[Project-specific database checks:
 - Migration sync verification (e.g. Drizzle journal, Prisma status, Alembic)
 - Check for pending schema changes
 - Warn if migrations are out of sync]

## Step 3: Run pre-deploy checks

[Run all checks sequentially, stop on failure:
 - Lint
 - Format check
 - Type check (if applicable)
 - Tests
 - Build]

[Use the exact commands from the project's package.json/Makefile/etc.]

### Adaptive checks (run based on what changed)

[Check the git diff and run additional checks where relevant:
 - **Database migrations present?** → Verify migration files are consistent with the ORM's state (e.g. Drizzle journal, Prisma status). Warn the user to review the migration SQL before deploying. Note the rollback approach (see Rollback section below).
 - **New dependencies added?** → Run the project's audit command (e.g. `npm audit`, `pip audit`) and flag any known vulnerabilities.
 - **New environment variables referenced?** → Check `.env.example` or equivalent for new entries and remind the user to set them in the hosting platform before deploying.
 - **Frontend changes?** → Note that design guideline compliance should have been verified in code review.]

## Step 4: Update changelog

Read `docs/changelog.md` and add an entry for this deployment.
Summarise what's changing based on the git diff — keep it concise.

Format:
```
## [Date]

- [Brief description of change 1]
- [Brief description of change 2]
```

Show the changelog entry to the user for approval before writing it.

## Step 5: Detect environment and sync

[Check if running in a worktree: `[ -f .git ]` — if .git is a file, we're in a worktree]

**If in a worktree:**
1. Sync with main before committing: `git fetch origin main && git merge origin/main`
2. If there are merge conflicts, STOP and help resolve — conflicts mean another worktree changed the same files
3. Never run `git checkout main` in a worktree
4. Never direct merge from a worktree — always use the PR flow in Step 7

**If on main:** proceed normally to Step 6.

## Step 6: Commit

[Stage changes, generate commit message following project conventions, create commit]

## Step 7: Push to deploy

**If in a worktree (PR flow):**
1. Rename branch from `claude/<name>` to project convention (e.g. `deploy/<date>` or `fix/<description>`): `git branch -m <new-name>`
2. Push: `git push -u origin <branch>`
3. Create PR: `gh pr create --base main --title "<title>" --body "<changelog summary>"`
4. Ask user: merge now (`gh pr merge --merge --delete-branch`) or wait for review
5. If merged and using push-to-deploy, deployment triggers automatically

**If on main (direct push):**
[Confirm with user before pushing]
[Push to the deployment branch]

## Step 8: Post-deploy steps

[Project-specific post-deploy actions:
 - Database migrations (if not automatic)
 - Cache clearing
 - Service restarts
 - Any manual steps the user needs to do in the hosting platform]

[Tell the user what will happen automatically and what they need to do manually]

## Step 9: Verify

[How to verify the deployment succeeded:
 - Health check URL
 - Where to monitor deploy progress
 - What to check in the application]

## If something goes wrong

[Project-specific rollback guidance:
 - **Quick rollback**: How to revert to the previous deployment (e.g. platform rollback button, `git revert` + push, redeploy previous commit)
 - **Database rollback**: If this deployment included migrations, how to revert them (e.g. ORM rollback command, or note if manual SQL is needed). If the migration is not reversible, state that clearly.
 - **What to check**: Key user flows and health endpoints to verify after rollback
 - **When to rollback vs fix forward**: If the issue is minor and the fix is obvious, fix forward. If the issue is unclear or affecting users, rollback first, investigate second.]
```

### Customisation requirements

The deploy skill must be **completely specific to this project**. Include:
- The exact test/lint/build commands from the project
- The exact database migration checks for the ORM in use
- The exact git branch and remote for deployment
- The exact hosting platform monitoring URL
- Any project-specific pre-deploy or post-deploy steps
- The changelog update step (always include this)
- **Worktree detection and safety** — the skill must detect worktrees and use the PR flow (never direct merge from a worktree)
- **Branch naming conventions** — the project's branch prefix conventions (e.g. `fix/`, `feature/`, `deploy/`)

### Present the deploy skill

> Project deploy skill created at `.claude/skills/deploy-[project]/SKILL.md`.
>
> From now on, use `/deploy-[project]` to deploy changes. The skill will:
> 1. Review changes
> 2. Verify database migrations
> 3. Run all checks (lint, format, type check, tests, build)
> 4. Update the changelog
> 5. Commit and push
> 6. Guide you through any post-deploy steps
>
> The first-time setup guide is at `docs/deployment/first-time-setup.md` — follow that to get to production initially.

## Step 4: Summary

> Deploy step complete.
>
> **Documents created:**
> - `docs/deployment/first-time-setup.md` — step-by-step first-time deployment guide
> - `.claude/skills/deploy-[project]/SKILL.md` — ongoing deployment skill
>
> **Next steps:**
> 1. Follow the first-time setup guide to get to production
> 2. After that, use `/deploy-[project]` for all future deployments
> 3. Once deployed, run `/uat` to conduct user acceptance testing in production
>
> ---
>
> You've now been through steps 1-5 of the Claude Code Project Framework. If the framework has been useful (or if you have suggestions for improving it), consider sharing your feedback: https://github.com/petebulley/claude-code-framework/issues

## Guidelines

### What NOT to do
- Do NOT actually deploy the project — create the guides and skill, the user follows them
- Do NOT skip the environment variables table — every env var must be documented
- Do NOT write a generic deploy skill — it must be specific to this project's stack and platform
- Do NOT forget the changelog step in the deploy skill — every deployment should log what changed
- Do NOT assume the user knows their hosting platform — be explicit about every step
