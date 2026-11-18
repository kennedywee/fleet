---
name: takeover
description: Take over existing work and finish its original goal, keeping the original contributors' credit. Use when the user asks to take over a PR, branch, or agent thread.
---

# Takeover

Take responsibility for finishing the original goal, and keep the original contributors' credit. Do
not defend an implementation just because another agent already built it.

## Read the handoff

Read the source PR, branch, or thread, including the review findings and the user's later
corrections. Resolve the handoff to the actual code and the current head, and account for
uncommitted work. Treat the handoff as context, not proof.

## Continue the work

For a replacement PR, import the original commits onto a new branch and add your fixes separately.
If the user explicitly asked for an in-place or stacked continuation, do that instead. Do not
overwrite unrelated work or change the original PR without authorization.

Use the `modernize` skill to update the continuation against its intended base and the current
architecture. Rework what is necessary to finish the same goal, not unrelated features. Simplify the
implementation without dropping intended behavior or surfaces. Recheck the source PR too: it may
have improved while you were working.

## Keep the credit

Keep Git authorship and existing co-author trailers. Credit the original contributors in the PR
description, and link the original PR when there is one.

If the work will be squashed, keep human author and co-author credit in the merge commit too. Use
verified identities, not guessed emails. Model attribution does not replace contributor credit.

## Verify

Verify the original failure and realistic workflows yourself. Follow the repository's guidance and
permissions. Green mocked tests do not prove that the user experience works. State what remains
unverified.

## Finish

When the requested finish includes a PR, use the `file-pr` skill to file or update it. Then use the
`babysit-pr` skill; do not stop at creation. Use the `leaving-pr-comments` skill for replies. Merge
or close the original PR only when authorized.

## Report

Report what you inherited, what you changed, how you verified it, how you kept the credit, and any
decision that remains.
