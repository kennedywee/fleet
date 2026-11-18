---
name: greploop-apps
description: Run the greploop review loop with the @greptile-apps trigger. Use when the normal @greptile trigger refuses a large PR. Needs the greploop skill.
---

# Greploop apps

Load the `greploop` skill and follow its workflow with `--trigger @greptile-apps`. Keep the user's
target, iteration cap, task scope, and existing authorization.

This skill is an entry point. It adds no rules of its own. Polling, freshness checks, and stopping
conditions all belong to `greploop`.

If the `greploop` skill is missing, report that and stop. Do not invent a second workflow. Do not
install anything unless the user asks.
