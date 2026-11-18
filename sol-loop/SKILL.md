---
name: sol-loop
description: Have OpenAI's GPT Sol review your code changes in a bounded loop, before or after filing a PR. Use when the user says "sol loop".
---

# Sol loop

Make your code changes more correct before you file a pull request, or sometimes after. A GPT Sol
reviewer reads the change, you answer its findings, and the loop repeats within a budget.

Make the smallest possible changes that satisfy the Sol reviewer. Watch for scope creep, and push
back when a finding is wrong.

## Budget

- The default is 3 rounds in total. Round 1 is a full review. Later rounds check only the changed
  code and the open findings.
- Extend to 5 rounds only when the user asks, or when the change touches security, permissions,
  auth, data loss, or state and concurrency, and a blocker or should stays open with evidence.
- Stop early if a round returns only nits. Declined nits, and fixes to comments, docs, or formatting
  only, need no new round.
- Use one reviewer only. Sol must not start subagents or reviewers.
- Keep a ledger: id, severity, outcome, and usage if it is returned. Never guess the usage.

## Scope

Run `git status --short`. Do not stash, discard, or include unrelated changes. Limit the review to
the paths of this change if they separate cleanly. Otherwise stop and ask.

Run `git fetch origin`, then find the base:

- **PR:** run `gh pr view <n> --json baseRefName,headRefOid`. Check out the branch only if the
  checkout is clean. Confirm that `HEAD` is the PR head, or ahead of it only by this change. The
  base is `git merge-base HEAD origin/<baseRefName>`.
- **Local:** the base is `git merge-base HEAD origin/<default-branch>`. With no remote, use a base
  the user names, or `HEAD` for uncommitted changes only.

The change is everything from the base to the working tree in those paths, including untracked
files. Use the same diff command in every round.

State the intent and what is out of scope in one or two sentences. Run the checks that cover the
change. Do not send code that this change breaks. Note missing checks, and checks that failed before
the change, in the brief.

## Start Sol

**In T3 Code:** call `orchestrator_capabilities`. Pick the latest Sol, unless the user named a
version. Do not hardcode an ID. Record the provider, model, and effort only if they are exposed.

Use `delegate_task` in every round, with `role: "review"` and `mode: "async"`. Save the `taskId`.
Use a new `clientRequestId` for each round. `childThreadId` is storage, not the next target. Do not
use `t3_thread_send`, `create_threads`, or `t3_thread_launch` for review.

If the T3 tools are not listed, try one direct capability call.

**Outside T3 Code:** use a native Sol subagent and keep its ID. In Claude Code, use a custom
subagent only if it is set up to run Sol.

If no route runs Sol, report the blocker. Do not substitute another model.

**While the review runs:** do not edit the scoped files. Wait for the notice. Do not poll, and do
not start a second reviewer. A timeout, an error, or no reply is not approval. On failure, cancel
the task, verify that it stopped, and restart with the ledger.

Send this brief in round 1. T3 child tasks get no history, so the brief must be complete:

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path> Base: <sha> Intent: <intent> Out of scope: <scope> Checks: <results>
See: git diff <base> [-- <paths>]; git status --short (read untracked).
Read surrounding code. Find bugs, broken callers, mismatch with intent.
Skip style unless it hides a bug. Hold to the smallest change. Flag code,
tests, or guards the intent does not need. Other paths, rare cases, small
perf, extra compat: nits.
blocker = intended case wrong. should = real bug callers will hit, in intent. nit = rest.
Reply:
VERDICT: APPROVE or CHANGES
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion> (stable ids)
```

## Answer findings

Check each finding and its severity yourself. A finding about another path, a rare case, or a small
cost is a nit, whatever label it came with.

- **You agree:** make the smallest fix. Prefer to delete or narrow code over a new lock, cache,
  helper, or option. Fix the case that happened. Add one focused test that fails without the fix, if
  the intent needs it.
- **You disagree:** say why, with evidence (file:line, a test, output).
- **Out of scope, or a nit:** decline in one line, and list it as a follow-up.

Update the ledger. Run the checks again, and run `git diff --shortstat <base>`. If the review grew
the diff, cut first. Do not agree just to end the loop.

## Next round

Start another round only if budget remains and one of these is true:

- a blocker or should is open;
- behavior code changed;
- the approval does not cover the current behavior diff.

In T3 Code, use a fresh `delegate_task`. Elsewhere, follow up with the saved native ID.

Send the round 1 brief, the ledger (`fixed:` / `disagree:` / `declined:` with evidence), the same
base diff, and the change since the last round. Tell Sol to review the open ids and the changed code
only, and to mark each old id `resolved` or `still open: <reason>`.

## Stop and ship

- **Agreed:** Sol gives APPROVE on the current behavior diff, no blocker or should is open, and you
  have no concern of your own.
- **Stuck:** an item stays disputed after two replies, or the budget ends. Show both sides in two or
  three lines each. The user decides. The end of the budget is not approval.

Do not push during the loop. After agreement, push only if the user asked you to push, ship, or
update the PR. If you push to a PR, add this line above the model and harness line in the
description:

`Reviewed with sol-loop: <N> rounds with <model>. Sol verdict: approved`.

Add `on <effort>` only if you verified the effort.

## Report

Report the rounds, the model, what Sol changed, the diff size before and after, the fixed and
declined findings with reasons, and whether you pushed. Report usage if it was exposed. If it was
not, say so.
