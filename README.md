# fleet

Kennedy's agent setup for every machine: skills, global instructions and Claude Code plugins. One
repo, pulled on each machine; `install.sh` links it into place.

## Layout

Every skill is a folder at the top level, holding its `SKILL.md`. `install.sh` links each one into
both Claude Code (`~/.claude/skills`) and Codex (`~/.codex/skills`).

The skills:

- **Pull requests:** `file-pr`, `full-stop`, `full-send`, `babysit-pr`, `takeover`,
  `leaving-pr-comments`, `council`, `sol-loop`, `modernize`.
- **Features and testing:** `new-feature`, `evidence-driven-testing`, `before-and-after`,
  `create-verification-skill`, `maintain-verification-skill`.
- **Review feedback:** `greploop`, `greploop-apps`.
- **Rails:** `dhh-rails`.
- **Writing:** `unslop`, `html-communication`, `html-upload`.
- **Planning:** `grill-me`, `grilling`.

Also here:

- `AGENTS.md`: global instructions, linked as `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.
- `plugins.txt` and `marketplaces.txt`: Claude Code plugins to install, and where from.
- `skills.txt`: upstream skills we use but do not keep here (`security-audit`). `install.sh`
  installs them for Claude Code and Codex with `npx skills`; `npx skills update -g` updates them.

**Not in the fleet** (laptop only): `omarchy`, `omarchy-app`, `diagnose-crash`, `superwhisper`. They
control the Omarchy desktop and come with Omarchy and Superwhisper themselves.

## Install on a machine

```sh
git clone https://github.com/kennedywee/fleet ~/fleet
~/fleet/install.sh
```

Then `git -C ~/fleet pull && ~/fleet/install.sh` to update. t3boat machines can do this on every
wake.

`install.sh` links each skill folder, so a pull updates skills in place. It only replaces links it
made: a real skill folder already on the machine is kept, unless you pass `--force`, which moves it
aside as `<name>.bak.<time>`. Skills deleted from the fleet lose their links.

## How the skills work

- **One machine per task, no worktrees.** Each feature runs on its own t3boat VM, so the VM is the
  isolation. `new-feature` makes a branch in the machine's checkout and stops if the checkout holds
  another task's work. `modernize`, `greploop` and `before-and-after` follow the same rule.
- **Before screenshots first.** `new-feature` captures the "before" while the branch still matches
  `main`. `before-and-after` reuses it, or uses a deployed baseline, and only as a last resort runs
  `main` from a temporary clone, one server at a time, with its own database when migrations differ.
  Two copies of the app never run at once on one machine.
- **Evidence goes to GitHub.** Screenshots and videos are attached to the PR with `gh --attach`, and
  only when the task asks for them. No other host is used.
- **Each project proves itself.** `create-verification-skill` writes a `verify-<app>` skill into a
  project: how to launch the app, how to drive it, and what proves each feature.
  `maintain-verification-skill` keeps it correct. `evidence-driven-testing` records and posts the
  proof.
- **Merging.** `full-send` may merge the PR, and only when you say "full send". `full-stop` does the
  same work and never merges.
- **Other models.** `council` and `sol-loop` ask other providers' models for review, through T3
  Code's `delegate_task`.

Requirements: `greploop` and `greploop-apps` need Greptile installed on the repo.
`evidence-driven-testing` needs `ffmpeg`/`ffprobe`, and Node 20+ for its Playwright helper.

## Change a skill

Edit it here, commit, push. Each machine gets it on its next pull.

- **Add a skill:** put its folder at the top level, and write it to the conventions below.
- **Use an upstream skill as is:** add a line to `skills.txt`, or to `plugins.txt` if it is a Claude
  Code plugin.

## Skill conventions

Every skill here reads as one set, whoever wrote it first. A skill copied from another repo is
rewritten to these rules when it comes in.

**Frontmatter**

- `name` and `description`, each on one line. Add another field only when it changes behavior
  (`disable-model-invocation`, `allowed-tools`). Leave out author, version and license.
- The description has up to three sentences. The first says what the skill does and starts with a
  verb. The second starts with "Use when" and gives the triggers. An optional third starts with "Not
  for". Put the user's trigger phrases in double quotes: `Use when the user says "full send".`

**Body**

- One `# Title`: the skill's name as words, in sentence case (`# Full send`).
- Then one short paragraph that states the outcome. No "when to use" section: the description does
  that.
- `##` sections in sentence case, without numbers. Use a numbered list for steps in order, and
  bullets for rules and cases. A step can start with a bold lead-in that ends in a period. A case
  starts with a bold label that ends in a colon.
- End with `## Report` when the skill ends with a report, and `## Requirements` when it needs tools
  that may be missing.
- Wrap prose at 100 columns.

**Voice**

- Follow the writing rules in `AGENTS.md`: short sentences, active voice, one idea per sentence.
- Give instructions to the agent in the imperative. Call the human "the user".
- Use "Never" for a hard limit and "Do not" for other rules.
- No XML tags, no words in capitals for emphasis, no decorative emoji, no em dashes.
- Do not mark what the fleet changed from upstream. The skill is ours.

**Links**

- Another skill: its name in backticks, as "the `file-pr` skill".
- A bundled file: a relative link, as `[GitHub](references/github.md)`. Keep long reference material
  in `references/` and tools in `scripts/`.

**Codex metadata**

- Every skill has `agents/openai.yaml` with `display_name`, `short_description` and
  `default_prompt`.

Keep this repo **private**.
