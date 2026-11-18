---
name: modernize
description: Bring an old pull request up to date and judge whether it still belongs. Use when the user asks to rebase a PR or says "modernize".
---

# Modernize

Modernize the idea, not just the branch. A clean rebase does not prove that the PR still belongs in
the product.

## Guardrails

- Before you start, pull the latest origin for your branch, the main branch, and any other branch
  related to your work.
- Treat uncommitted changes as the user's. Each task runs on its own machine, so do not create
  worktrees. If the checkout is dirty or holds another task's work, stop and ask. Do not stash,
  reset, or switch branches.
- Modernizing authorizes rebasing and updating the PR branch. It does not authorize merging,
  closing, changing the base branch, or expanding the scope.
- Never use an unqualified force push. Update a rebased branch with `--force-with-lease` against the
  head SHA that you observed before the rebase.
- Do not post a PR comment unless the user asked for one. Use the `leaving-pr-comments` skill for
  every comment that you post for the user.

## Establish the PR's intent

Resolve the PR and record its URL, state, base, head repository and branch, current head SHA,
author, checks, and review state. Read the title, body, linked issues, commits, review threads, and
the complete diff. Before you judge the implementation, state the smallest coherent goal that the PR
tried to accomplish.

Fetch the latest remote base and PR head. Use the PR's actual base branch, usually `main`. Do not
assume that the local branch is current. Record the merge base, so you can compare the original PR
and the later base-branch changes separately.

## Check what changed around it

Inspect the commits and diffs added to the base branch since the PR diverged. Search merged and open
PRs when titles, code paths, or behavior suggest a replacement or a competing implementation.

Look beyond overlapping lines:

- Has the same user-facing problem already been solved?
- Did APIs, types, schemas, dependencies, or architectural boundaries change?
- Do both sides now claim ownership of the same behavior or invariant?
- Was the code being changed deleted, moved, or intentionally simplified?
- Would landing the PR restore an old behavior or create two ways to do the same thing?
- Is the original benefit still large enough to justify the maintenance cost?

Do not call a PR current merely because Git reports no conflicts.

## Choose a disposition before pushing

Use one of these recommendations:

- **MODERNIZE:** the goal is still useful and the implementation is still the right shape. Rebase,
  resolve conflicts, test, and update the branch.
- **REWORK:** the goal is still useful, but a mechanical rebase would keep the wrong implementation.
  Explain the smallest credible rewrite. Stop before pushing, unless the user also asked for that
  rework.
- **CLOSE:** the PR is superseded, obsolete, directionally wrong, or no longer worth its cost. Cite
  concrete evidence and stop. Do not spend time rebasing an obsolete branch, and do not close it
  without explicit permission.

Be willing to recommend `CLOSE`. Age alone is not evidence, and sunk effort is not a reason to keep
a PR alive.

## Rebase without losing intent

For a `MODERNIZE` disposition:

1. Create a safe local branch at the recorded PR head.
2. Rebase its commits onto the freshly fetched base branch.
3. Resolve each conflict according to the PR's current intent and the base branch's newer
   invariants. If a conflict reveals a product or architecture disagreement, stop and reconsider the
   disposition. Do not guess.
4. Compare the commit series before and after the rebase with `git range-diff`, and inspect the
   final diff. Confirm that no intentional behavior disappeared and no already-landed behavior was
   reintroduced.
5. Run the repository's focused checks for the touched area. Separate real failures from
   pre-existing or infrastructure failures.
6. Push with `--force-with-lease` tied to the remote head that you observed earlier. If the lease
   fails, fetch and reassess. Do not overwrite new work.

Do not merge the PR.

## Report

Lead with `MODERNIZE`, `REWORK`, or `CLOSE` and the reason. Then summarize:

- the meaningful changes on the base branch;
- the conceptual conflicts, or confirmation that you found none;
- the rebase and push result, if performed;
- the checks you ran and their results;
- the remaining decision or work, with a link to the PR.

Separate observed facts from judgment. Say what you could not verify. Do not manufacture confidence.
