---
name: greploop
description: Address Greptile feedback on a GitHub PR through bounded review and fix cycles. Use when the task includes a Greptile review loop. Supports the alternate @greptile-apps trigger for large PRs.
---

# Greploop

Improve the requested change with Greptile feedback. Success means a fresh 5/5 review of the current
revision, with no unresolved actionable Greptile findings. The bot's score adds to the project's
checks and your judgment. It does not replace them.

## Inputs

- A PR number. Infer it from the current task when it is omitted.
- `--max-iterations N`, a positive integer. The default is 10 review cycles.
- `--trigger @greptile` by default, or `@greptile-apps` for the alternate route. Use the alternate
  when the normal trigger reports too many changed files.

Apply the user's existing authorization and task scope. A read-only review request does not
authorize code edits or posting comments. Keep your own task's branch on this machine. Do not switch
another task's checkout to the PR branch.

## The review helper

Read [references/github.md](references/github.md) before the first cycle. The bundled helper,
`scripts/github_review.py`, tracks each trigger and waits for a scored review tied to the current
commit.

## Review cycle

1. **Prepare.** Confirm the target revision, clean task ownership, and the effective iteration cap.
   Run the relevant checks before you publish edits, then push them.
2. **Start one review attempt** with the review helper. Record its trigger and revision. Wait at
   most 10 minutes for fresh results. Do not reuse an earlier score just because it belongs to the
   same commit.
3. **Read everything.** Read the entire fresh summary, including general-comment findings. Fetch all
   pages of unresolved Greptile threads. An empty inline-comment list does not prove that the
   summary contains no remaining work. Older unresolved threads stay relevant until addressed, even
   after their lines become outdated.
4. **Decide.** If the current review is 5/5, no actionable Greptile findings remain, and the
   relevant checks pass, finish. Otherwise evaluate each finding in context. Fix valid issues within
   the task. For a false positive, record the reason and the supporting evidence before you resolve
   it. Do not change correct code merely to chase the score, and do not resolve other reviewers'
   threads.
5. **Publish the fixes.** Run the checks for the fixes. Commit only task files, with explicit file
   paths when staging. Push, then resolve the specific threads whose fixes are published. If no code
   changed, skip the commit and the push.
6. **Repeat.** Start a new attempt for the resulting revision if the cap permits it. A changed head
   invalidates the old attempt. Do not reuse an attempt file, and do not retrigger merely because a
   poll has not returned yet.

## When to stop

Stop when the cap is reached, a review times out, the integration is unavailable, or the remaining
findings need a scope decision. The iteration cap includes reviews that produce no edits.

Report the actual result and the remaining work. Do not raise the cap automatically, and do not call
a partial result complete.

## Report

Give the PR URL, the reviewed revision, the number of cycles, the current score, the checks you ran,
the resolved findings, and the remaining findings. Separate a successful review from a timeout or a
capped run. Do not merge unless the user asked.

## Requirements

- Greptile must be installed on the repository.
- Python 3.10+ and an authenticated `gh`.
