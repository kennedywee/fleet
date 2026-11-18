# fleet

Kennedy's agent setup for every machine: skills, global instructions and Claude Code plugins.
One repo, pulled on each machine; `install.sh` links it into place.

## Layout

Every skill is a folder at the top level, holding its `SKILL.md`. `install.sh` links each one
into both Claude Code (`~/.claude/skills`) and Codex (`~/.codex/skills`).

Where the skills come from:

- Own: `html-communication`, `html-upload`.
- Theo's PR skills: `babysit-pr`, `council`, `file-pr`, `full-send`, `full-stop`,
  `leaving-pr-comments`, `modernize`, `sol-loop`, `takeover`.
- Ras Mic's stack: `new-feature`, `code-structure`, `evidence-driven-testing`,
  `before-and-after`, `unslop`, `greploop`, `greploop-apps`.
- Others: `dhh-rails`, `grill-me`, `grilling`, `find-skills`.

Also here:

- `AGENTS.md`: global instructions, linked as `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.
- `plugins.txt` and `marketplaces.txt`: Claude Code plugins to install, and where from.
- `skills.txt`: upstream skills we use but do not keep here (`security-audit`). `install.sh`
  installs them for Claude Code and Codex with `npx skills`; `npx skills update -g` updates them.
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

- Theo's PR skills, from [t3dotgg/tstack](https://github.com/t3dotgg/tstack), MIT. The
  license text is in that repo, not here.
- Ras Mic's stack, from [michaelshimeles/skills](https://github.com/michaelshimeles/skills).
  His own skills (`new-feature`, `code-structure`, `evidence-driven-testing`) have **no license**,
  so they are here for private use only: never make this repo public with them inside. The
  borrowed ones are licensed upstream, with the text in their source repos: `unslop` and
  `greploop*` are MIT, `before-and-after` is PolyForm Shield 1.0.0 (any use but a product that
  competes with its author).

`SOURCES.md` records the commit each was copied from, to compare with upstream later.

Our changes to copied skills are marked "fleet change":

- **One machine per task, no worktrees.** Each feature runs on its own t3boat VM, so the VM is
  the isolation. `new-feature` makes a branch in the machine's checkout and stops if the
  checkout holds another task's work. `modernize`, `greploop` and `before-and-after` follow
  the same rule.
- **Before screenshots first.** `new-feature` captures the "before" while the branch still
  matches `main`. `before-and-after` reuses it, or uses a deployed baseline, and only as a last
  resort runs `main` from a temporary clone, one server at a time, with its own database when
  migrations differ. Two copies of the app never run at once on one machine.
- `before-and-after` never uploads unless a host is named (it defaulted to the public 0x0.st).

Notes on Ras Mic's skills: `greploop` and `greploop-apps` need Greptile installed on the repo.
`evidence-driven-testing` needs `ffmpeg`/`ffprobe`, and Node 20+ for its Playwright helper.

Notes on Theo's skills: `full-send` may **merge** the PR (only when you say "full send");
`full-stop` does the same work and never merges. `council` and `sol-loop` ask other providers'
models for review, through T3 Code's `delegate_task`.

## Change a skill

Edit it here, commit, push. Each machine gets it on its next pull.

- **Add a skill:** put its folder at the top level.
- **Third-party skill we change:** copy it in and add a line to `SOURCES.md`.
- **Third-party skill we only use:** add a line to `skills.txt`, or to `plugins.txt` if it is a
  Claude Code plugin.

Keep this repo **private**: several skills are other people's work.
