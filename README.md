# fleet

Kennedy's agent setup for every machine: skills, global instructions and Claude Code plugins.
One repo, pulled on each machine; `install.sh` links it into place.

## Layout

Each folder is a **scope**. Its `.targets` file names the agents that get its skills.

| Folder | Goes to | What |
|---|---|---|
| `universal/` | Claude Code, Codex | Rails, Inertia, shadcn, UI and web skills, HTML write-ups |
| `claude/` | Claude Code | `impeccable`, `security-audit` |
| `codex/` | Codex | `grill-me`, `grilling` |
| `video/` | Claude Code, `~/.agents` | HyperFrames and media skills |
| `agents/` | `~/.agents` | `find-skills` |
| `pr/` | Claude Code, Codex | Theo's PR skills: `full-stop`, `full-send`, `file-pr`, `babysit-pr`, … |
| `rstack/` | Claude Code, Codex | Ras Mic's stack: `new-feature`, `code-structure`, `evidence-driven-testing`, `before-and-after`, `unslop`, `greploop` |

Targets: `claude` is `~/.claude/skills`, `codex` is `~/.codex/skills`, `agents` is `~/.agents/skills`.

Also here:

- `AGENTS.md`: global instructions, linked as `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.
- `plugins.txt` and `marketplaces.txt`: Claude Code plugins to install, and where from.
- `SOURCES.md`: where each third-party skill came from.

**Not in the fleet** (laptop only): `omarchy`, `omarchy-app`, `diagnose-crash`, `superwhisper`.
They control the Omarchy desktop and come with Omarchy and Superwhisper themselves.

## Install on a machine

```sh
git clone https://github.com/kennedywee/fleet ~/fleet
~/fleet/install.sh
```

Then `git -C ~/fleet pull && ~/fleet/install.sh` to update. t3boat machines can do this on every
wake.

`install.sh` links each skill folder, so a pull updates skills in place. It only replaces links it
made: a real skill folder already on the machine is kept, unless you pass `--force`, which moves
it aside as `<name>.bak.<time>`. Skills deleted from the fleet lose their links.

## Copied skills

Some skills started as someone else's and are ours to change now:

- `pr/`: Theo's PR skills from [t3dotgg/tstack](https://github.com/t3dotgg/tstack), MIT. Keep
  `licenses/tstack-MIT.txt` with them.
- `rstack/`: Ras Mic's stack, from [michaelshimeles/skills](https://github.com/michaelshimeles/skills).
  His own skills (`new-feature`, `code-structure`, `evidence-driven-testing`) have **no license**,
  so they are here for private use only: never make this repo public with them inside. The
  borrowed ones keep their own `LICENSE`: `unslop` and `greploop*` are MIT, `before-and-after` is
  PolyForm Shield 1.0.0 (any use but a product that competes with its author).
- `templates/rstack-AGENTS.md`: his workflow file, meant for a repo's root (not global). Copy it
  into a repo and replace its "Checks in this repo" section with that repo's checks.

`SOURCES.md` records the commit each was copied from, to compare with upstream later.

Our changes to copied skills are marked "fleet change":

- **One machine per task, no worktrees.** Each feature runs on its own t3boat VM, so the VM is
  the isolation. `new-feature` makes a branch in the machine's checkout and stops if the
  checkout holds another task's work. `modernize`, `greploop`, `before-and-after` and the
  `rstack-AGENTS.md` template follow the same rule.
- `before-and-after` never uploads unless a host is named (it defaulted to the public 0x0.st).

Notes on Ras Mic's skills: `greploop` and `greploop-apps` need Greptile installed on the repo.
`evidence-driven-testing` needs `ffmpeg`/`ffprobe`, and Node 20+ for its Playwright helper.

Notes on Theo's skills: `full-send` may **merge** the PR (only when you say "full send");
`full-stop` does the same work and never merges. `council` and `sol-loop` ask other providers'
models for review, through T3 Code's `delegate_task`.

## Change a skill

Edit it here, commit, push. Each machine gets it on its next pull.

- **Add a skill:** put its folder in the right scope.
- **New scope:** a folder with a `.targets` file, e.g. `echo "claude codex" > rails/.targets`.
- **Third-party skill:** copy it in and add a line to `SOURCES.md`.

Keep this repo **private**: several skills are other people's work.
