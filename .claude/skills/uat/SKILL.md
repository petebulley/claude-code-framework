---
description: Walk through user acceptance tests one by one, guide the user step by step, fix issues found, and mark tests as passed
---

# UAT — User Acceptance Testing

You are guiding the user through manual user acceptance testing of the deployed application. The test plan lives in `docs/uat.md` in the project root — it contains scenarios written during each `/implement` phase.

**Core principle:** Assume the user has NO prior knowledge of the application's UI, navigation, or internals. Every instruction must be explicit, specific, and self-contained. The user is following your instructions literally — ambiguity causes false negatives.

**Prerequisites:**
- The application must be deployed to a testable environment (production or staging)
- `docs/uat.md` must exist with test scenarios (written during `/implement` phases)
- The project's deploy skill (`/deploy-[project]`) must exist for deploying fixes

## Step 1: Show progress and find the next test

Read `docs/uat.md` and count all tests by status. Present a progress summary:

> **UAT Progress**
>
> | Status | Count |
> |--------|-------|
> | Passed | X of Y (XX%) |
> | Failed | X of Y (XX%) |
> | In Progress | X of Y (XX%) |
> | Not Started | X of Y (XX%) |
>
> **Overall: X / Y complete (XX%)**

Use the status indicators from the file: `✅` Passed, `❌` Failed, `⏳` In Progress, `⬜` Not Started.

Then find the first test with status `⬜ Not Started` or `❌ Failed`. Skip any tests marked `✅ Passed`.

Present the test to the user:

> **Next test: UAT-X.X: [Test Name]**
>
> [Brief description of what this test covers]

If ALL tests are marked `✅ Passed`, congratulate the user — UAT is complete!

> **UAT Complete!**
>
> All [Y] tests passed. The application has been verified in production.
>
> **Next steps:**
> - Continue building — run `/implement` for the next phase
> - Make changes — run `/work` for features, tweaks, or bug fixes
> - Re-run UAT after significant changes to verify nothing has regressed
>
> ---
>
> You've completed the full Claude Code Project Framework cycle — from idea to deployed, tested product. If the framework helped (or if you have ideas for improving it), consider sharing your feedback: https://github.com/petebulley/claude-code-framework/issues

## Step 2: Prepare the test environment

Before presenting test steps, analyse the test requirements and provide **explicit setup instructions**. Consider:

### Browser and session state
- **Tests requiring "not logged in":** Instruct the user to open an **Incognito/Private window** (Cmd+Shift+N on Mac, Ctrl+Shift+N on Windows/Linux). Explain why: "This ensures no existing session cookies interfere with the test."
- **Tests requiring a specific account type:** Tell the user exactly which account to use and how to identify it.
- **Tests requiring a fresh/new user:** Instruct the user to use an Incognito window AND sign in with an account that has never been used with the application before.
- **Tests requiring a second user:** Explain they need a different account, and that they should use a separate Incognito window or browser profile so sessions don't conflict.
- **Tests requiring existing data:** Verify with the user that the prerequisite data exists before starting. If it doesn't, help them create it first or note which earlier test creates it.

### Device and viewport
- **Desktop tests:** "Open your browser and ensure the window is at least 1024px wide. You can check by opening DevTools (F12) and looking at the viewport dimensions."
- **Mobile tests:** "In Chrome DevTools (F12), click the device toggle toolbar (phone/tablet icon) and select a mobile preset like 'iPhone 14' or manually set width to 390px. Alternatively, test on an actual phone."
- **Responsive tests:** Explain both viewports need testing and how to switch between them.

### Prerequisites checklist
Present a clear checklist before starting:

> **Before we begin, confirm:**
> 1. [Environment requirement — e.g., "Open an Incognito window"]
> 2. [Account requirement — e.g., "You have a test account ready"]
> 3. [Data requirement — e.g., "You have at least 2 items already created"]
> 4. [Device requirement — e.g., "Browser window is at least 1024px wide"]

Wait for the user to confirm all prerequisites are met before proceeding.

## Step 3: Walk through the test steps

Mark the test as `⏳ In Progress` in `docs/uat.md` by editing the status line.

Present each step one at a time with **maximum specificity**.

### How to write each step instruction

1. **State the action explicitly:** Don't say "Navigate to the settings page." Say "In your browser address bar, go to `https://[app-url]/settings` (or click 'Settings' in the left sidebar — it has a gear icon)."

2. **Describe exactly what to look for:** Don't say "Verify the page loads." Say "You should see a page with the heading 'Settings' and sections for Profile, Notifications, and Appearance below it."

3. **Describe UI element locations precisely:** Use spatial language — "top-right corner", "left sidebar", "bottom of the page", "the tab bar below the heading". Reference visual cues — "a blue button labelled 'Save'", "a circular profile photo in the top-right", "a hamburger menu icon (three horizontal lines)".

4. **Explain what constitutes pass vs fail:** Don't just say "check that it works." Say "This step passes if you see [specific outcome]. It fails if you see [specific failure mode — blank page, error message, wrong redirect, missing data, etc.]."

5. **Call out common gotchas:** If a step is timing-sensitive (e.g., waiting for data to load), say so. If something might look different on first use vs subsequent use, mention it.

### Step presentation format

> **Step X of N:** [Clear, detailed action]
>
> **What to do:** [Exact clicks/navigation/typing required]
>
> **What you should see:** [Precise description of expected visual outcome]
>
> **This step passes if:** [Specific pass criteria]
>
> Tell me what you see.

After each step, wait for the user's response:

- **Passed as expected** — move to the next step
- **Something looks wrong** — the user will describe the issue

### Between steps
If the test context changes between steps (e.g., "now sign out and try as a different user"), provide full transition instructions — don't assume the user knows how to sign out, switch accounts, or clear state.

## Step 4: Handle issues

If the user reports an issue during any step:

1. **Clarify before investigating:** Ask targeted questions to distinguish between a real bug and a test execution issue:
   - "Are you in an Incognito window or a regular browser window?"
   - "Which account are you signed in as? (Check the avatar/email in the top-right corner — or wherever the app shows the current user)"
   - "What URL does your browser address bar show right now?"
   - "Can you describe exactly what you see on screen?"

2. **Investigate the issue** — read relevant code, check the deployment logs, reproduce the problem

3. **Propose a fix** and implement it after user approval

4. **Deploy the fix** using the project's deploy skill (`/deploy-[project]`)

5. **Once deployed, restart the current test from the beginning:**
   - Re-present the setup instructions (Step 2)
   - Walk through ALL steps again from Step 1 to verify the fix works and nothing else broke
   - Do NOT just re-test the broken step — the fix might have affected other steps

## Step 5: Mark the test result

After ALL steps in a test pass:

1. Update the test status in `docs/uat.md` from `⏳ In Progress` to `✅ Passed`
2. Tell the user the test passed

If a test cannot be completed due to a blocker that can't be fixed right now:

1. Update the status to `❌ Failed`
2. Add a **Failure Notes** section below the test with the issue description and date
3. Move on to the next test

```markdown
**Failure Notes:**

- [Date]: [Description of what failed and why it couldn't be fixed immediately]
```

## Step 6: Continue or stop

After marking a test, immediately offer the next action:

> **UAT-X.X: [Test Name] — Passed ✅** (or Failed ❌)
>
> **Progress: X / Y complete (XX%)**
>
> Options:
> - **Continue** — move to the next test
> - **Stop for now** — progress is saved in `docs/uat.md`
> - **Jump to a specific test** — tell me which test number

If the user wants to continue, go back to Step 1 and find the next uncompleted test.

## Guidelines

### Specificity is everything
- **Always specify the full URL** when directing the user to a page (e.g., `https://myapp.com/settings` not just "go to settings")
- **Never assume the user knows how to perform common actions** — signing out, opening DevTools, switching browser profiles, checking which account they're signed into — always provide the exact steps
- **Be specific about WHERE to look and WHAT to click** — the user is following your instructions literally
- **When a test requires a clean session**, always instruct the user to use an Incognito/Private window and explain why
- **When multiple accounts are needed**, explain how to manage them without session conflicts (separate Incognito windows or browser profiles)

### Testing discipline
- Always update `docs/uat.md` in real-time as tests progress — this is the source of truth
- Never mark a test as `✅ Passed` unless the user explicitly confirms all steps passed
- Keep the flow conversational but focused — one step at a time
- When fixing issues, always deploy and retest the ENTIRE test (not just the broken step)

### What NOT to do
- Do NOT skip setup instructions — even if the test seems simple, always prepare the environment
- Do NOT mark tests as passed without the user confirming each step
- Do NOT batch multiple steps together — present one step at a time and wait for confirmation
- Do NOT assume the user knows the application — treat every instruction as if it's their first time using it
- Do NOT leave `docs/uat.md` stale — update status in real-time
- Do NOT fix issues without deploying and retesting — a fix isn't verified until UAT passes
