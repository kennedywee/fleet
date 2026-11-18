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

## Change a skill

Edit it here, commit, push. Each machine gets it on its next pull.

- **Add a skill:** put its folder in the right scope.
- **New scope:** a folder with a `.targets` file, e.g. `echo "claude codex" > rails/.targets`.
- **Third-party skill:** copy it in and add a line to `SOURCES.md`.

Keep this repo **private**: several skills are other people's work.
