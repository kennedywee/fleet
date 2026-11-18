# fleet

Kennedy's agent setup for every machine: skills, global instructions and Claude Code plugins.
One repo, pulled on each machine; `install.sh` links it into place.

## Layout

Each folder is a **scope**. Its `.targets` file names the agents that get its skills.

| Folder | Goes to | What |
|---|---|---|
| `universal/` | Claude Code, Codex | Rails, Inertia, shadcn, UI and web skills, HTML write-ups, `evidence-driven-testing` |
| `claude/` | Claude Code | `impeccable`, `security-audit` |
| `codex/` | Codex | `grill-me`, `grilling` |
| `video/` | Claude Code, `~/.agents` | HyperFrames and media skills |
| `agents/` | `~/.agents` | `find-skills` |
| `pr/` | Claude Code, Codex | Theo's PR skills: `full-stop`, `full-send`, `file-pr`, `babysit-pr`, … |

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
- `universal/evidence-driven-testing`: Ras Mic's, from
  [michaelshimeles/skills](https://github.com/michaelshimeles/skills). It has **no license**, so it
  is here for private use only: never make this repo public with it inside.

`SOURCES.md` records the commit each was copied from, to compare with upstream later.

Notes on Theo's skills: `full-send` may **merge** the PR (only when you say "full send");
`full-stop` does the same work and never merges. `council` and `sol-loop` ask other providers'
models for review, through T3 Code's `delegate_task`.

## Change a skill

Edit it here, commit, push. Each machine gets it on its next pull.

- **Add a skill:** put its folder in the right scope.
- **New scope:** a folder with a `.targets` file, e.g. `echo "claude codex" > rails/.targets`.
- **Third-party skill:** copy it in and add a line to `SOURCES.md`.

Keep this repo **private**: several skills are other people's work.
