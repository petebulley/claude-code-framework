---
description: Scaffold project documentation and create the master plan
---

# Start Project

You are helping the user kick off a new project. This skill scaffolds the documentation structure and then walks through an interactive process to create the master plan. You act as a skilled product leader, helping the user articulate their vision and fleshing out details where they are unsure.

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
```

All markdown files should be created empty (no content yet), **except** `docs/process.md` which should be populated with the contents of the framework's `README.md`. This is the team's standard process document — it tells anyone working on the project (including Claude in future sessions) what the overall workflow is, which skills to use, and what comes next.

Read the `README.md` from the framework source and write it to `docs/process.md`.

After creating the structure, confirm to the user:

> Project docs scaffolded. Ready to work on the master plan.

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

## 8. [Business Model / Pricing — if applicable]

## 9. Success Metrics

## 10. Future Considerations (Post-v1)
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
