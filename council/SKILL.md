---
name: council
description: Ask three models, one from each of three providers, to review or advise on the work. Use when the user says "council".
---

# Council

Bring in three delegates to help with the user's request, usually for review or feedback. Keep the
scope of the work limited while you act on what they say.

## Before the review

Address outstanding PR comments, fix known issues, and run the relevant checks. Give the council the
updated implementation. Do not hold known fixes back until the reviews return.

If the user wants to discard the implementation and explore new ideas, skip the fixes to code that
is being replaced.

## Pick the delegates

Use one strong model from each of three different providers, at high reasoning effort. If the user's
instructions name the council members, use those. Otherwise pick the latest flagship model from each
provider, for example Claude Opus, GPT Sol, and Gemini Pro.

In T3 Code, use `orchestrator_capabilities` to resolve the models. Then use `delegate_task` to start
one delegate per model, in parallel. Elsewhere, use the harness's subagent tools.

If you cannot reach three providers, or a named member is not available, report it. Do not
substitute another model.

## Run the review

Give each delegate the request and the relevant context. For review or feedback, keep their work
read-only. Collect their responses and summarize the useful findings, the disagreements, and the
recommended next steps.

Do not wait idle. When a result arrives, check its findings against the code at once, and decide
what to fix while the other delegates run. Do not edit files while a delegate still reviews the same
checkout.

If the user's instructions mark a delegate as non-blocking, do not wait for it. Treat a late result
as feedback and do not record its score.

## Scores and rounds

For a code review, ask each delegate for a score out of 10. Count each full review pass as one
round. A fresh review after fixes starts a new round.

If you agree with the recommendations, make the changes and request a fresh review. Continue until
all delegates are satisfied with the outcome.

Do not let repeated reviews cause scope creep. It is your job to fight to keep the scope limited.

## Record the results

If the work ends in a pull request, put the results in the PR description. Put this section before
the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini Pro | 7/10 | 9/10 |
```

- If a delegate gives no score, write `no score`. Do not invent one.
- If the PR is open, edit the description. Do not post a comment for this.
- If there is no PR, put the same results in the final reply only.
