---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR.
---

# File PR

File a pull request whose title and description tell a reader why the change matters.

## Before you file

Check whether a PR for this branch already exists. Review the diff locally against the base branch
(usually `origin/main`) and make sure its contents match the goal.

## Title

PR titles usually become commit messages, so follow the repository's title conventions. Look at
recently merged PRs and the Git history for examples. Prefer a short, human-readable title that says
why the change matters.

Bad:

> perf(server): negotiate permessage-deflate on the websocket

Good:

> perf(server): cut websocket frame size by 70%+ with gzipping

## Description

Open with a simple explanation of the problem, based on the user's original prompt. Then explain the
solution briefly. Do not lead with an inventory of the implementation.

Bad:

> Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

Good:

> My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

End the description with the public model name and the harness that made the changes, for example
`Created with <model> in <harness>.` Include subagent models that wrote part of the change. Use the
model name that the harness reports. If the model identity is not available, name the harness and do
not guess a model.

## Submit

1. Check the title, description, quotes, and attachments for secrets and private details.
2. Open a real PR, not a draft, so review bots run.
3. If `gh pr create` fails because the GraphQL rate limit is used up, open the PR through REST: `gh
   api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
4. If the user also asked you to babysit the PR, continue with the `babysit-pr` skill.

Do not post a follow-up PR comment unless it serves the user's request. When a comment is needed,
use the `leaving-pr-comments` skill.
