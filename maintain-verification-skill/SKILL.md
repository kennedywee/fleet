---
name: maintain-verification-skill
description: Check a project's verification skill and feature map against the app, and correct what no longer matches. Use when the user asks to "maintain the verification skill" or "audit the verify skill", or when a verify skill's steps fail on a working app.
---

# Maintain a verification skill

Bring a project's `verify-<app>` skill back in line with the app. A feature map goes out of date
each time the app changes. Cover each feature file from the source and drive each feature live. Ship
only corrections that you proved.

## Outcomes

End with one of these outcomes, and say which:

- **Clean:** each feature has source and live coverage, and nothing needs a change. No branch, no
  PR.
- **Changed:** one PR ships proven corrections to the skill, its helper scripts, or its map.
- **Blocked:** the coverage could not finish, or a proven fix could not ship safely. Say exactly
  what blocked it.

## Edit scope

Edit only the verification skill's own folder: its `SKILL.md`, its `features/`, and the scripts that
it owns. Never edit product code during this work.

When the map describes a behavior that the app no longer has, decide which one is wrong:

- **The map is out of date:** correct the map.
- **The app has regressed:** report it to the user. Do not change the map to hide it.

## Steps

1. **Find the skill.** Look for the project-local skill that has launch and drive sections and a
   feature map, usually `.agents/skills/verify-*/`. If there are several, ask which one. If there is
   none, stop and point to the `create-verification-skill` skill.
2. **Check the index.** Read the feature map's `README.md` and list the files next to it. Correct
   missing, extra, duplicate, and dead entries.
3. **Read the source.** For each feature file, read how the feature works in the code today. Note
   each place where the file no longer matches, with the `file:line` that shows it. Write one short
   recipe to check the feature live.
4. **Look for missing features.** Read the recent commits for new user-facing surfaces: routes,
   pages, commands. Call a feature missing only when you can name its source path.
5. **Drive each feature.** Do this even when the source reading found nothing. Follow the skill's
   own Launch section, and drive each feature at least once. Keep the live rules below.
6. **Sort what you found.** Use the three cases in "Sort the findings".
7. **Ship or stop.** For a changed outcome, read each changed file again. Then start a branch with
   the `new-feature` skill and open one PR with the `file-pr` skill. For a clean or blocked outcome,
   open no PR.

## Live rules

Hold these rules for the whole live pass:

- **Doctor before you drive.** Run the doctor check before the first drive and after each failed
  drive. When the doctor check cannot see the fault, for example a stuck page on a healthy process,
  reset to a known state or launch again.
- **Evidence survives cleanup.** After each cleanup, look in the named folder and confirm that the
  evidence is there.
- **Leave nothing behind.** Stop what a drive started when that drive ends, also when it failed.
  Stop only what you started.

More cases:

- **The doctor check fails because the skill is out of date:** correct the skill and try once more.
  Restart only what the correction changed. If it fails again, the outcome is blocked.
- **A feature cannot be reached:** record the exact prerequisite (login, plan, operating system,
  external state) and the path that you tried. If the map does not name that prerequisite, add it.
- **You corrected a helper script:** drive it live again before you ship it.

Tear down everything after the last drive, including the drives that proved a correction. Keep the
evidence.

## Sort the findings

- **Map fault:** the description is wrong or missing from the user's point of view. Correct the
  file.
- **Harness gap:** the behavior works, but the skill cannot drive it. Correct the recipe or the
  helper. A helper stays executable, with its invocation shown in the skill body.
- **Product fault:** the app is broken. Record it for the user, and keep it out of this PR.

## Report

Tell the user:

- the outcome: clean, changed, or blocked;
- the features that you covered, and the ones that you could not reach, with the prerequisite;
- each correction, with the evidence that proves it, and the PR link when there is one;
- each product fault that you found.

Keep your run notes in a scratch folder. Do not commit them.

## Requirements

- A project with a verification skill from the `create-verification-skill` skill, or another
  project-local skill with launch and drive sections and a feature map.
- A machine where the app starts.
