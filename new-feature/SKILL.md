---
name: new-feature
description: Start a feature, fix, or documentation change on its own branch in this machine's checkout, without Git worktrees. Use when starting any task that edits a repository. Not for read-only reviews and investigations.
---

# New feature

Give each editing task its own branch in this machine's checkout.

Each editing task runs on its own machine (a t3boat VM). The machine is the isolation: it has its
own checkout, ports, databases, and dependencies. Do not create Git worktrees.

Create the branch from the latest `origin/main`, unless the user gives a different base. Read-only
work can use the checkout as it is. Never build on `main`. Never reuse another task's branch or
work.

## Check the checkout first

Run `git status --short` and `git branch --show-current` in the repository's checkout.

- **On a branch for this task already:** keep it. Skip steps 3 and 4.
- **On `main` with a clean tree:** follow all steps.
- **On another task's branch, or with changes you did not make:** stop. Do not switch branches,
  stash, or reset. This machine belongs to that task. Tell the user, and suggest a new machine for
  this task in t3boat.

Do not decide this from the branch prefix alone. Look at the branch's commits and the changes.

## Steps

1. **Sync.** Run `git fetch origin`.

2. **Check the scope.** Run `gh pr list`. Skim the changed files of the open PRs (`gh pr diff <n>
   --name-only`). For shared files, read the overlapping diffs. Independent edits can continue. Ask
   for direction only when the changes conflict in behavior, need another task's unfinished work, or
   ownership is not clear. If `gh` is not available, say that the scope check was not done, and
   continue.

3. **Name the task.** Use lowercase words with hyphens, plus a short unique suffix. Example:
   `user-auth-0816a`. If the branch name exists, choose a different name. Never force or reuse.

4. **Create the branch** from the latest `origin/main`:

   ```bash
   git switch -c <branch-prefix>/<task-name> origin/main
   ```

   Use the same branch prefix every time (example: `agent/`). If the repository has its own
   conventions, follow them.

5. **Verify.**

   ```bash
   git branch --show-current   # must print your new branch, not main
   ```

   Confirm the required runtime version. Install dependencies when the task's checks need them.
   Documentation-only work does not need the application's full toolchain.

6. **Capture the before state** when the change affects what users see. Do this only while the
   branch still matches `main`. If the branch already holds edits, skip this step: a capture now
   would show the change, not the before. The `before-and-after` skill has other ways to get the
   baseline. Run the app and take the before screenshots. The tool takes two URLs, so give the same
   page twice and keep the first image:

   ```bash
   npx @vercel/before-and-after "<url>" "<url>" -o ~/evidence/<task-name>/before
   ```

   Note the viewport and selector you used, and use the same ones for the after. Later, the
   `before-and-after` skill pairs the saved before image with the after. This avoids running an old
   copy of the app next to the new one.

## While you work

- **One task per machine.** A second task on the same machine shares its checkout, ports, and
  databases. Ask the user to start another machine instead.
- **Push the branch often.** The machine sleeps when idle, and a deleted machine loses work that was
  not pushed.

## Clean up

After the PR is merged or closed:

```bash
git switch main && git pull --ff-only
git branch -D <branch-prefix>/<task-name>
```

`-D` is expected. After a squash or rebase merge, `-d` refuses, although the work is merged.
