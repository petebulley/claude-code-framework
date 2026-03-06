---
description: Quickly capture a bug, feature idea, or improvement to the task list without breaking your current flow
---

# New Issue

The user has spotted something mid-flow — a bug, a feature idea, an improvement, a "we should fix that later". Your job is to capture it to `docs/tasks.md` with enough context that `/work` can pick it up later, then get out of the way so the user can continue what they were doing.

**Speed is everything.** The user is mid-development and wants to log this quickly, not start a planning session. Total interaction should be under 2 minutes.

## Step 1: Understand what they've spotted

The user will describe the issue. From their description, figure out:

- **What it is** — bug, feature, improvement, or tech debt
- **The gist** — one-line summary of the problem or idea
- **Current vs desired** — what happens now vs what should happen (for bugs/improvements)

If their description is clear enough to write a good task entry, skip straight to Step 2 — don't ask questions you already know the answer to.

If you need clarification, ask **one message** with 2-3 targeted questions. Don't interrogate. Examples:

> Quick questions:
> - Is this a bug (something broken) or an improvement (something that could be better)?
> - What should happen instead?

Or for a feature idea:

> Got it. Just to capture this well:
> - Where in the app would this live?
> - Any specific behaviour you have in mind, or just the general idea for now?

## Step 2: Gather context (only if useful)

Quickly scan for relevant context — but only if it genuinely helps write a better task entry. Don't research for the sake of it.

**Do:**
- Grep the codebase to identify the 1-3 most relevant files (so `/work` knows where to start)
- Note any obvious dependencies or risks you spot

**Don't:**
- Deep-dive into the code — that's `/work`'s job
- Web search for solutions — that's `/work`'s job
- Investigate root causes — that's `/work`'s job
- Spend more than 30 seconds on this step

## Step 3: Add to tasks.md

Read `docs/tasks.md` and add the issue in the appropriate place.

### Where to put it

- If there's an existing section that fits (e.g., a phase section or feature section), add it there
- If not, add it under a **Backlog** section at the end of the file (create the section if it doesn't exist)

### Task entry format

For **bugs:**

```markdown
- ⬜ Bug: [Clear description of what's broken and what should happen instead]
  - Files: `[relevant-file.ts]`, `[other-file.ts]`
```

For **features:**

```markdown
- ⬜ Feature: [Clear description of what to build]
  - [One line of additional context if needed]
  - Files: `[relevant-file.ts]` (if known)
```

For **improvements / tech debt:**

```markdown
- ⬜ Improvement: [Clear description of what to improve and why]
  - Files: `[relevant-file.ts]`
```

### Writing good task entries

The entry must be self-contained — when someone runs `/work` and picks this task weeks later, they should understand what to do without needing to ask the original reporter. Include:

- **What**, not just a title — "Bug: Calendar widget shows wrong timezone for users outside UTC" not "Bug: timezone issue"
- **Current vs desired** baked into the description where relevant
- **Relevant files** — 1-3 files maximum, only the most relevant starting points
- Skip priority and effort labels — `/work` will assess those when it picks up the task

## Step 4: Confirm and move on

Present a brief confirmation and get out of the way:

> **Logged to `docs/tasks.md`:**
>
> ⬜ [Type]: [Task description]
>
> Pick it up later with `/work`. Back to what you were doing.

That's it. Don't summarise, don't suggest next steps, don't offer to investigate further. The user wants to get back to their current work.

## Guidelines

- **Be fast** — this is a capture tool, not a planning tool
- **Be conversational** — ask what makes sense, not a checklist
- **Skip what's obvious** — if the type and description are clear, don't ask
- **Write for future context** — the task entry should make sense to someone (or Claude) picking it up later without the original conversation
- **One message of questions max** — if you need to clarify, do it in a single message with 2-3 targeted questions
- **Don't scope it** — don't estimate effort, don't plan the implementation, don't suggest solutions. Just capture it.
- **Don't start fixing it** — the user didn't ask you to fix it, they asked you to log it

### What NOT to do
- Do NOT investigate the issue in depth — just capture it
- Do NOT propose solutions or implementation approaches
- Do NOT start multiple rounds of questions — one message max
- Do NOT add priority/effort labels — keep it simple
- Do NOT forget the relevant files — they save time when `/work` picks it up
- Do NOT write a novel — bullet points, brief descriptions, done
