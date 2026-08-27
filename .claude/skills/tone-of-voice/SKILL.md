---
description: Create a tone of voice guide by interviewing the user and measuring how they actually write, or apply an existing guide when drafting prose in their voice. Use when writing content that will be published under the user's name, when prose "sounds like AI", or when the user asks for a voice, tone, or style guide.
---

# Tone of Voice

Two modes. Work out which one applies before doing anything.

| Situation | Mode |
|---|---|
| A guide already exists and you are writing prose | **Apply** |
| No guide exists, or the user asks to create or revise one | **Create** |

Look for a guide in this order and use the first one found:

1. `docs/definition/tone-of-voice.md` in the current project — or the nearest
   equivalent if the project does not follow the framework's docs structure
2. `~/.claude/tone-of-voice.md`

A project-local guide layers on top of the personal one. It adds constraints; it never
contradicts them. Read both when both exist.

---

# Mode: Apply

Read the guide, then write. Afterwards, check your draft against the guide's own rules
rather than against your instincts.

If the guide has a machine-checkable list, run it over your draft before showing the
user. Report honestly if you could not meet a threshold and say which one.

If a rule in the guide conflicts with what the user just asked you to do, follow the
user and say that you did.

**Do not apply the user's voice to your own session messages, commit messages or code
comments.** A voice guide governs prose written *as the user*, for a reader who will
attribute it to them. Your own messages are yours.

---

# Mode: Create

The output is a guide, written to `~/.claude/tone-of-voice.md` unless the user says
otherwise. This is an interview, not a research task. Do not go away and produce a
draft. Ask, wait, and gather real material first.

Tell the user up front that this takes a while — expect 30 to 45 minutes, most of it
them supplying samples and correcting your drafts. It is not a background task.

### Pre-step: Check for framework updates

Before starting, check if the framework has updates available:

```bash
SKILL_LINK=$(readlink ~/.claude/skills/tone-of-voice 2>/dev/null) && \
FRAMEWORK_DIR=$(dirname "$(dirname "$(dirname "$SKILL_LINK")")") && \
[ -f "$FRAMEWORK_DIR/bin/check-update.sh" ] && \
bash "$FRAMEWORK_DIR/bin/check-update.sh"
```

- If the output says **UPDATE AVAILABLE**, tell the user and offer to update now. If they
  agree, run the same command with `--pull` at the end.
- If there is no output, continue silently — the framework is up to date (or offline).

Skip this in Apply mode. Interrupting someone mid-draft to talk about framework versions
is not worth it.

## The failure mode you are trying to avoid

**A generic writing guide.** "Be clear, be concise, use active voice, prefer the
concrete." That describes all good writing, constrains nothing, and is worthless. If a
rule you are about to write would apply equally to any competent writer, delete it.

**Every rule must be traceable to something in the samples.** Where you make a decision
the samples do not support, mark it as a decision rather than presenting it as an
observed habit.

## Step 1: Gather real material

Ask for these, one at a time, and wait for each.

- **Three or four things they have actually written.** Real artefacts, not descriptions
  of how they write. Blog posts, internal documents, an email, a README, strategy
  writing. Offer to pull from wherever they live: a URL, a file path, a connected tool.
- **Which samples are which register.** Work writing and personal writing are usually
  different voices. If the samples are all one kind, ask explicitly which one the
  current project should sound like.
- **Provenance.** Ask whether anything was drafted by someone else, ghostwritten, or
  edited by a marketing or comms team. Discount anything uncertain and say in the guide
  that you did. Building rules from copy someone else wrote encodes the wrong voice.
- **Whether the ideas in the target writing are theirs.** Advocating your own position
  and explaining someone else's idea are different jobs. If the samples are all the
  first and the target is the second, the guide needs a section on what transfers and
  what does not.
- **Who the audience is**, and whether the voice shifts between audiences or only the
  amount of explanation does.

If they can only find one sample, work with one and say so in the guide.

## Step 2: Measure before you interpret

Compute this, do not estimate it. **Write a script and run it.** Counting by eye
produces confident, wrong numbers, and every rule downstream rests on these figures.
Keep the script — you will run it again in Step 4 against your own drafts, and the
machine-checkable rules in Step 6 need the same tooling to validate their patterns.

Compare the user's samples against whatever corpus represents the problem, which is
usually existing content that prompted the request.

Strip markup, navigation, headings, tables and boilerplate first, or you will measure
the tooling instead of the person.

**Sentence shape**
- Mean, median and standard deviation of sentence length in words
- Share of sentences at 8 words or fewer, and at 30 or more
- p10 and p90

**Per 1,000 words**
- Contractions
- First person singular, first person plural, second person
- Parentheses, colons, semicolons, em dashes, question marks
- Hedges: `usually|often|typically|tends? to|in general|generally|likely|rarely`
- Absolutes: `never|always|every|only|nothing|nobody`

**Structure**
- Paragraph length in sentences, and the share of one-sentence paragraphs
- How pieces open and how they close
- Verbless or fragment-shaped sentences

Quantify. "Mean 22 words against 16, with a 25% short-sentence rate against 8%" is
usable. "They write crisply" is not.

**Expect the numbers to contradict your assumptions.** Run them before forming a view.
It is common for AI-written prose to be *choppier* than the person's, not more verbose,
in which case advice to "keep sentences short" would make things actively worse.

## Step 3: Get one rewritten passage

**This is worth more than all the samples combined.** Point the user at a specific,
short passage of the problem content and ask them to rewrite it however roughly.

Make it easy to do:
- Pick something short. One paragraph is enough.
- Tell them rough is better than polished.
- Tell them to write it as though publishing, not as though marking your draft, and to
  start from the idea rather than editing your sentences.

If they say they cannot rewrite it because they do not understand it, **that is a
finding, not a failure.** Record it. Comprehensibility on one read belongs in the
judgement list.

## Step 4: The calibration loop

Now write, and have them correct. This is the highest-yield part of the process and it
should run at least twice.

1. Draft a short passage applying what you have learned so far.
2. Measure your own draft against the same statistics. Report honestly where you missed.
3. Ask them to correct it.
4. **Extract the rule from each edit they make.** Every change is a data point. Ask what
   the edit has in common with their earlier edits.

Small edits carry the most information. An edit that makes prose *longer* is especially
valuable, because it means something outranks brevity for this writer, and that will not
appear in any generic guide.

Where a question would be better answered by showing than asking, show. To find out
whether the voice shifts between audiences, write the same paragraph twice and ask which
is right, rather than asking them to describe the shift in the abstract.

## Step 5: Show the analysis before writing the guide

Present the measurements, the traits, and the quotes that support each claim. Let the
user correct it. Misreading a voice is far cheaper to fix at this stage.

Quote their own writing back at them whenever you make a claim about it.

## Step 6: Split the rules into two lists

They get used differently and mixing them makes both useless.

### Machine-checkable

Things a script can find. Give exact strings or regexes. **Validate every pattern against
the real corpus and record the hit count.** Precision matters more than coverage: a rule
that produces false positives gets switched off, and then nothing is checked at all.

Prefer **density thresholds per file** over per-instance rules for anything that has
legitimate uses, such as colons, absolutes or short sentences. Set thresholds generously
against the user's own measured rate so ordinary writing never trips them.

Before shipping a pattern, test it against a sentence the user actually wrote. If it
fires on their own prose, tighten it or move it to the judgement list.

### Judgement

Things only a careful read can assess. Whether a paragraph is comprehensible on one
read, whether it earns its length, whether a vivid phrase is standing in for a
mechanism, whether it sounds like an impression of good writing rather than the thing
itself.

## Step 7: Cover the AI tells, with the right reasoning

Read <https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing> and use it. If you
cannot fetch it, say so and work from the list below instead. Pull real
examples from the user's problem content rather than listing the tells generically. If a
tell does not appear in their corpus, say so and keep it as cheap insurance rather than
presenting it as a live problem.

Tells worth checking for:
- Negative parallelism, both the same-sentence form ("not just X but Y") and the
  two-sentence form ("X is not Y. It is Z."), which is the same device split across a
  full stop and is easy to miss
- Copula avoidance: "serves as", "stands as", "represents", "acts as" in place of "is"
- Undue significance: "crucial", "pivotal", "key", "vital", "essential"
- Participial tails tacked on for false profundity
- Rule-of-three padding
- Uncontracted, uniformly declarative register

**Distinguish inflation from real logical work.** "It is not just a framework, it is a
way of thinking" is inflation. "Not because they cannot prioritise, but because they
lack a system" rejects one cause and asserts another, which is legitimate and something
people genuinely write. A rule that cannot tell these apart will fire on the user's own
sentences and be switched off.

### On em dashes specifically

If the user avoids em dashes, establish **why** before writing the rule, because it
changes its scope.

Most people who avoid them now did not always. They stopped because readers treat them
as a marker of machine-written text. If so, **the rule is about perception, not
correctness**, and two things follow:

1. It applies to prose written as the user, not to a session's own messages.
2. **The replacement must not be another tell.** Swapping every em dash for a semicolon,
   a colon, or a "not just X but Y" trades one signal for another. Check the user's
   natural semicolon and colon rates, and if they are low, add density caps so
   substitution is caught.

Show what a genuine replacement looks like: usually a full stop, sometimes a comma,
often a restructured sentence. Put a before-and-after table in the guide.

## Step 8: Prove it works

Rewrite a real passage against the finished guide and show it beside the original. Ask
whether it sounds like them.

**If it does not, the guide is wrong. Iterate on the guide, not on the rewrite.**

Do not rewrite the rest of the content. That is a separate and much larger job that
happens once the guide is agreed.

## What the guide should contain

1. Scope: what it governs and what it does not
2. The evidence base, with each sample's weight and any discounted for provenance
3. The measurements, as a table, against the corpus that prompted the request
4. Observed traits, each with a quotation from the user's own writing
5. What transfers and what does not, if the target writing has a different purpose
6. Machine-checkable rules, with validated patterns and hit counts
7. Judgement rules
8. A worked before-and-after example
9. Anything recorded as a decision rather than an observed habit, marked as such

Keep it applicable. A guide nobody can act on is decoration.
