# Ledger verification map

This folder is the maintained source for verifying what a user can do in Ledger. Read this index
before you drive the app. Then use the matching feature file as the recipe.

Ledger is an invented app. Copy the shape of these files, not their commands.

## Baseline

- Launch Ledger at `http://localhost:3000` from an empty database, with `make verify-up`. It
  migrates, seeds, and starts the app.
- The seed creates the user `owner@ledger.test` with the password `password123`, and the customers
  `Acme` and `Borneo Supplies`.
- Run the doctor check. It must report the expected URL, the commit under test, and a working login.
- Never drive an instance that this run did not start.

## Driving rules

- Start each recipe from the baseline, unless its preconditions say otherwise.
- Prefer ARIA roles and accessible names to CSS selectors and DOM position.
- Treat each command as literal. Keep quoted names unchanged.
- Wait for a selector or a URL after each navigation.
- Restore the seeded data after a change. Do not remove the evidence during cleanup.

## Proof and skips

- Capture the user's action and the resulting state, not only the final screen.
- UI proof is a screenshot with the page identity visible, and the text of the element that changed.
- A change to stored data also needs a second, read-only view of the stored value.
- Record the feature and the entry point with each capture.
- Report a path that you could not reach, with the command you tried and the missing precondition.
- Do not report a skipped entry point as verified through another path.

## Feature file contract

Each feature file starts with a `#` title and one paragraph that describes what the user can do.
Then it has these four `##` sections, in this order:

1. `Sub-features`: short IDs, with one line for each behavior.
2. `How to reach it`: every entry point a user has.
3. `How to drive it`: the preconditions, then one bullet for each step. Each bullet pairs the user's
   action with the exact command and the result that you can observe.
4. `Gotchas`: the traps that waste a run or make it invalid.

Keep implementation details out of the map. Name only user paths, stable handles, required state,
commands, and observable proof.

## Features

- [Create an invoice](create-invoice.md): creation from two entry points, validation, cancellation,
  and the stored record.
