---
name: fleet-sync
description: Update this machine's skills, global instructions, and plugins from the fleet repo. Use when the user says "fleet sync" or asks to sync or update the fleet on this machine.
---

# Fleet sync

Bring this machine up to date with the fleet: pull the fleet checkout, then run its `install.sh`.
The sync runs only when the user asks for it. Do not schedule it, and do not run it as a side step
of other work.

## Steps

1. **Find the checkout.** This skill is a link into the fleet checkout. Resolve it:
   `fleet="$(dirname "$(readlink -f ~/.claude/skills/fleet-sync)")"`. On a machine without Claude
   Code, use `~/.codex/skills/fleet-sync` or `~/.gemini/config/skills/fleet-sync`. Confirm that
   `$fleet/install.sh` exists.
2. **Look before you pull.** Run `git -C "$fleet" status --short --branch` and record the current
   commit with `git -C "$fleet" rev-parse HEAD`. Use the cases below when the checkout is not clean
   or not on `main`.
3. **Pull.** Run `git -C "$fleet" pull --ff-only`.
4. **Install.** Run `"$fleet/install.sh"`. It links each skill, removes the links of skills that
   left the fleet, links the global instructions, and installs missing upstream skills and plugins.
5. **Check.** List the links in `~/.claude/skills`, `~/.codex/skills` and
   `~/.gemini/config/skills`, and confirm that none points at a missing folder.

## Cases

- **Uncommitted changes:** the user edits the fleet on this machine. Do not stash, reset, or commit.
  Pull only if Git can do it with the changes in place. If it cannot, stop and report.
- **Local commits that are not pushed:** pull as usual, and name the commits in the report. Never
  push. The user decides when the fleet is published.
- **The pull is not a fast-forward:** stop and report. Do not merge or rebase.
- **The checkout is on another branch:** stop and ask. Do not switch branches.
- **`install.sh` skips a folder:** a real folder sits where a link belongs. Report its path. Never
  pass `--force` unless the user asks for it.

## Report

Tell the user:

- the commits that the pull brought in, from `git log --oneline <old>..HEAD`, or that the checkout
  was already current;
- each link that `install.sh` added or removed, and each folder that it skipped;
- local commits that are not pushed, and uncommitted changes;
- that a running agent session loads new skills only after it restarts.

## Requirements

- A clone of the fleet repo on this machine, installed once by hand with `install.sh`.
- `git`, with access to the fleet's remote.
