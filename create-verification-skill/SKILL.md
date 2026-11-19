---
name: create-verification-skill
description: Generate a project-local skill that launches the app, drives it the way a user does, and captures proof. Use when the user asks to "create a verification skill" or "make a verify skill for this repo", or when a project has no scripted way to prove runtime behavior.
---

# Create a verification skill

Write a `verify-<app>` skill into the project, so that every later agent can start the real app,
exercise a feature the way a user does, and capture proof. The reader of that skill is an agent that
has never seen the app and opens the skill in the middle of a task. Write for that reader.

The generated skill owns what is specific to the app: how to launch it, how to drive it, and what
proves each feature. The `evidence-driven-testing` skill owns how to record and post proof. Do not
repeat one in the other.

## Read the repo first

Answer these questions from the codebase. Ask the user only for what you cannot observe.

- **Surface:** what does a user touch? A web UI, a CLI, an API, a mobile app? If the repo has
  several, pick the main one and note the others.
- **Run:** how does the app start locally? Prefer the repo's own command (a package script, a
  Makefile target, the README quickstart). Note the ports, environment variables, seed data, and
  login.
- **Drive:** how can an agent operate it? Look for an existing harness first: system tests,
  Playwright specs, request helpers, a console. Only then pick a general recipe: Playwright for a
  web UI, a tmux session for a CLI, plain HTTP for an API.
- **Observe:** what can you capture? Screenshots, response bodies, logs, exit codes, database rows.
- **Isolate:** each task runs on its own machine, so the machine is the isolation. Note what the app
  shares outside the machine, such as a remote database, a mail provider, or a payment sandbox.

If the checkout does not build or start, fix that first, or report exactly what fails. A skill
written against a broken app teaches wrong steps.

## Write the skill

Create `.agents/skills/verify-<app>/SKILL.md`. Claude Code reads `.claude/skills`, so make sure the
skill is visible there:

- **`.claude/skills` does not exist:** link it to `../.agents/skills`.
- **`.claude/skills` is a real folder:** link `.claude/skills/verify-<app>` to
  `../../.agents/skills/verify-<app>`.
- **The project already keeps its skills in another place:** follow the project.

Follow the fleet's skill conventions. The frontmatter has `name: verify-<app>` and a description
that names the app, the surface, and when to use the skill. Without frontmatter, the skill does not
load.

Write these sections from what you found. Leave no placeholder.

- **Launch:** the exact commands that start the app from an empty database, including migrations and
  seeds, and the sign that it is ready. Ready means usable: a health check can pass before the app
  can serve a real page. Include how to stop it. For a CLI, launch means build once, then start each
  run in its own session.
- **Doctor:** one read-only check that answers "is this instance worth driving?". It confirms that
  the process is up, that it runs the commit under test, that it owns the port, and that login
  works. An agent runs it first, and again whenever something looks wrong.
- **Drive:** the recipe with real commands and selectors from this repo. Prefer stable handles: ARIA
  roles, accessible names, data attributes, and route paths. Do not use coordinates or tab order.
- **Evidence:** what to capture for a proof and where it goes. Include the proof rules below. Point
  to the `evidence-driven-testing` skill for recording and posting.
- **Cleanup:** how to stop what the run started and remove its scratch state. Stop a process by the
  PID that you started, never by name. Cleanup never removes the evidence. Name the folder where the
  evidence stays.
- **Gotchas:** the traps that wasted your time while you wrote the skill.

If the skill ships a helper script, make it executable and show its invocation in the skill body. A
helper that the reader must reverse-engineer does not help.

## Proof rules

Put these rules in the Evidence section of the generated skill:

- Exercise the real user path. Do not call internal setters or test-only endpoints.
- Capture the action and the resulting state, not only the final screen.
- Check the side effects next to what is visible: rows inserted, files written, jobs enqueued, mail
  sent.
- Use a mock only where production already isolates the external system.
- When the safe path is a dry run or a test mode, observe what it skips. Do not trust its name.

## Seed the feature map

Create `.agents/skills/verify-<app>/features/README.md` and one file for each user-facing feature.
Start with the three to five most important features. Find them in the routes, the navigation, the
commands, or the docs.

Follow the shape in [the feature map example](references/feature-map-example/README.md). Each
feature file answers four questions from the user's point of view: what the feature is, how to reach
it, how to drive it, and which end state proves that it works.

If the seed data lacks something that a feature needs, write the reason in that feature's Gotchas
and report it. Never weaken a recipe to make it pass.

The map is the project's maintained source for verification. A proof that drives one convenient
entry point is incomplete when the map lists others.

## Prove the skill before you hand it over

Run the generated skill once, end to end, exactly as written:

1. Launch the app.
2. Run the doctor check.
3. Drive one mapped feature. One is enough. The map exists so that later runs cover the rest.
4. Capture the evidence.
5. Clean up.
6. Confirm that the evidence still exists in the named folder.

Fix what fails. Run the cleanup after each failed attempt too, so that no process or port is left
behind. A skill that you never ran is a draft.

If you proved the skill somewhere other than its real target, for example on a laptop instead of a
fresh machine, list each setup step that the stand-in already had. Those steps stay unverified.

## Report

Tell the user:

- the path of the generated skill and the features in its map;
- which feature you drove, and where the evidence is;
- what stays unverified, and why;
- that the `maintain-verification-skill` skill keeps the map correct as the app changes.

Do not commit or open a PR unless the user asked for it.

## Requirements

- A project that builds and starts on this machine.
- A way to drive the surface. For a web UI: Node 20+ and Playwright, which the helper in the
  `evidence-driven-testing` skill can run without adding it to the project.
