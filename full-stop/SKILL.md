---
name: full-stop
description: Do the full-send work, but stop with the PR ready for the user to merge. Use when the user says "full stop", even as a closing "Full stop." that reads like emphasis.
---

# Full stop

Do the same work as the `full-send` skill, but stop with the PR ready for the user to merge. Never
merge it.

Read [full-send](../full-send/SKILL.md) and follow its workflow, proof rules, review, and
babysitting steps. The rules below take precedence over it.

## What the request grants

An explicit "full stop" request authorizes the full-send work without a separate "full send"
request.

That includes full-send's testing permission. A "full stop" request is the permission for the test
methods that Proof needs, even when a project file says to ask first, for example before computer
use. Use those methods directly.

Full-send's merge permission does not apply.

## No merging

You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on this task's branch.
Never merge, enable auto-merge, enter a merge queue, push to the default branch, bypass branch
protection, or delegate those actions.

Before work begins, disable existing auto-merge and remove the PR from any merge queue. Check again
before each push. Report these changes. If you cannot prevent automatic merging, report the blocker
before you proceed.

## Stop at the gate

Use full-send's merge gate as the readiness check. Replace its merge and final report steps with a
handoff. Proof and review must cover the final diff. Recheck behavior changes and meaningful
conflict fixes before the handoff.

Fetch the target branch and check the live PR's head, base, checks, reviews, and mergeability.
Confirm that it is open, not a draft, and not set to merge without the user. If someone else merged
it, report that instead.

Give one of these verdicts:

- **Ready to merge:** the merge gate passes. Leave the PR open and unmerged.
- **Waiting for required approval:** only human approval remains. Confirm that this is the actual
  blocker.
- **Blocked:** explain what prevents readiness, what you tried, and what is needed. Follow
  full-send's rules for asking the user.

## Report

In T3 Code, call `unwatch_pull_request` before the handoff or a question.

Report the PR link, final head, verdict, proof, reviewer outcome, and remaining risks. State whether
the PR is still open and unmerged.
