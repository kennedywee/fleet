---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses a "grill" trigger phrase.
---

# Grilling

Interview the user relentlessly until you reach a shared understanding. Map the interview as a
**design tree**: every decision branches into the decisions that hang off it.

## Work in rounds

The **frontier** is every decision whose prerequisites are already settled. These are the questions
you can ask now without guessing at answers you have not heard yet.

Ask the whole frontier in one round. Number each question and give your recommended answer. Then
wait for the user's answers before the next round.

Format each question like this:

```
**Q1. <question title>**

<question body, might be multiple paragraphs>

- **A:** <choice, when the question has choices>
- **B:** <choice>

**Recommended:** <your recommended answer, with the reason in one sentence>
```

Each round of answers reshapes the tree. Settled decisions push the frontier outward and unblock the
questions that depended on them. Recompute the frontier and ask the next round. A question whose
answer depends on another question still open in this round belongs to a later round.

## Facts are your job

Finding facts is your job, never the user's. When a frontier question needs a fact from the
environment (the filesystem, tools, and so on), dispatch a subagent to find it. Do not ask the user
for anything you can look up yourself.

Do not block on the lookup. A running exploration is an unsettled prerequisite, so only the
questions downstream of it wait for the subagent to report. Ask the rest of the frontier now.

The decisions are the user's. Put each decision to them and wait.

## When to stop

The session is done when the frontier is empty: every branch of the design tree is visited, and
nothing is silently assumed. Do not act on the result until the user confirms that you have reached
a shared understanding.
