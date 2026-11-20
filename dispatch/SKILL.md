---
name: dispatch
description: Hand each task to its own linked machine in T3 Code, one thread per machine, and track the threads to their PRs. Use when the user says "dispatch", or asks to send tasks to VMs or other machines.
---

# Dispatch

Give each task to one free machine and follow it until its PR is ready. You are the orchestrator.
You do not edit the project yourself.

The machine is the isolation. Each one runs one task at a time, in one thread, in the project's main
checkout. Never use a Git worktree on a machine, and never put a second task on a machine that holds
one.

You work only with machines that are already linked in T3 Code. The user creates and deletes the
VMs. Never create, delete, stop, or reset a machine.

## What the request grants

- Start one top-level thread on each machine that gets a task.
- Run the `fleet-sync` skill on each machine that you are about to use.
- Clone and register the project on a machine that does not have it.

The request does not grant a merge. Each thread runs "full stop", unless the user said "full send"
for these tasks.

## Tasks

List the tasks before you look at machines. Each task needs a goal that a new agent can act on with
no history: the repository, the issue or the problem, and what done looks like. If a task is not
clear enough to hand over, ask the user about it now. Continue with the others.

Check that the tasks are independent. Two tasks that edit the same code go to one machine, one after
the other, or the user decides the order.

## Find the machines

1. **List.** Call `t3_environment_links`. Keep the machines with status `reachable`. If the user
   named machines, use only those.
2. **Drop the busy ones.** Call `t3_thread_list` for each machine with `allProjects` and the active
   statuses. A machine with an active thread is busy.
3. **Check the project.** Call `t3_project_list` for each machine. Match the project by its
   repository, not by its title. Keep the path of every project on the machine, not only this
   one. The preflight checks them all.

A machine with no active thread can still hold a task. A thread that ended with its PR open keeps
the machine, in any project. Only the preflight can tell.

If a machine the user named is not linked, call `t3_environment_link` with a hint from the user's
words.

## Preflight

Run the preflight on a machine right before you give it a task. Use one `delegate_task` with
`target.environmentId`, `role: "general"`, and `mode: "async"`. Send this brief:

```
Preflight only. Do not edit a project, switch branches, stash, or reset.
1. Use the fleet-sync skill. If this machine has no fleet checkout, say so and continue.
2. For each of full-stop, full-send, new-feature, evidence-driven-testing, before-and-after,
   sol-loop, file-pr, babysit-pr: readlink -f <skills folder>/<name>. Each must be a folder
   inside the fleet checkout.
3. In each of <project paths>: git fetch origin; git status --short --branch; git rev-parse HEAD.
4. Where the branch is not main: gh pr list --head <branch> --state all
   --json number,state,url,headRefOid.
5. gh auth status.
Reply:
FLEET: current at <sha> | updated <old>..<new> | missing | failed: <reason>
SKILLS: all from the fleet | not from the fleet: <names>
CHECKOUT <path>: <branch>, clean | dirty, HEAD <sha>, PR <number> <state> head <sha> | no PR
GH: ok | failed: <reason>
```

Give one `CHECKOUT` line per project. `<skills folder>` is the one for the harness that the thread
will use: `~/.claude/skills` or `~/.codex/skills`.

Read the reply against these cases:

- **Ready:** the fleet is current or updated, every skill comes from the fleet, every checkout is a
  clean `main`, and `gh` works.
- **Left over from a merged or closed PR:** a checkout is clean, its branch belongs to a PR that is
  merged or closed, and its `HEAD` is that PR's head. Send a second task that runs the clean-up
  from the `new-feature` skill in that checkout. Then run the preflight again.
- **Holds open work:** a checkout in any project is dirty, or its branch has an open PR or no PR, or
  its `HEAD` is not the PR's head. Commits that the PR does not hold exist only on this machine, and
  the clean-up would delete their branch. The machine belongs to that task. Do not use it, and
  report the commits.
- **No fleet, or the sync failed:** do not use it. An agent without the fleet does not know "full
  stop", and does the work its own way.
- **A skill is not from the fleet:** a real folder sits where the link belongs, so the thread would
  load an old copy. Do not use the machine. Report the names. Never pass `--force` to `install.sh`.
- **No project:** clone it with `t3_project_clone`, register it with `t3_project_create`, and run
  the preflight again.
- **`gh` fails:** do not use it. The thread could not push or open a PR.

Never repair a machine beyond these cases. Report it as not ready, with the reply.

## Hand over

Start one thread per task with `t3_thread_launch`:

- `environmentId`: the machine.
- `projectId`: the project on that machine.
- `workspaceStrategy`: `{ "type": "root" }`. Never `worktree`.
- `title`: the task in a few words.
- `message`: the brief below.

Use `t3_thread_launch`, not `delegate_task`. A delegated child cannot watch a PR, so it cannot
babysit one. The user can also open a top-level thread and talk to it.

The thread gets no history. The brief must be complete:

```
<goal: the issue or problem, with its link, and what done looks like>
<constraints the user gave, and what is out of scope>
This machine is yours for this task. Work in the project's main checkout. Do not create a Git
worktree.
Full stop.
```

Put "Full send." in place of "Full stop." only when the user asked for a merge. Never put a secret
in the brief.

If no machine is ready for a task, do not start it. Report it as waiting, with the reason for each
machine.

## Track

Keep a ledger in your replies: task, machine, thread link, PR, state.

Wait with `t3_thread_wait`. Do not poll, and do not send a thread a message to ask for progress.
When a thread ends or waits, read it with `t3_thread_read`:

- **It reports a PR:** record the link and the verdict.
- **It asks a question:** answer it only when the user's request already holds the answer.
  Otherwise bring the question to the user, with the thread link.
- **It stopped because the machine holds another task:** the preflight missed it. Mark the machine
  busy, and give the task to another ready machine.
- **It failed:** read why. Start it again on the same machine only when the checkout is still clean.

Never watch a PR yourself. The thread that owns the PR watches it.

## A machine is free again

A machine is free when its PR is merged or closed and every checkout on it is back on a clean
`main`. The next preflight does that clean-up. Until then the machine holds its task, even when its
thread has ended, because the user may send review fixes to that thread.

## Report

Give the user the ledger: each task with its machine, its thread link, its PR link, and the verdict
from the thread. List the tasks that wait for a machine and the machines that are not ready, with
the reason for each. Say what the fleet sync changed on each machine.

## Requirements

- T3 Code with linked environments. Without `t3_environment_links`, report that, and tell the user
  to enable Settings → Labs → Linked environments.
- On each machine: the fleet installed once with `install.sh`, the project's repository reachable,
  and `gh` logged in.
