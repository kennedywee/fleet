---
name: before-and-after
description: Capture before and after screenshots of web pages or elements for visual comparison. Use when the user says "take before and after", "screenshot comparison", "visual diff", "PR screenshots", or "compare old and new", or needs to document a UI change. Accepts two URLs (file://, http://, https://) or two image paths.
allowed-tools:
  - Bash(npx @vercel/before-and-after *)
  - Bash(before-and-after *)
  - Bash(which before-and-after)
  - Bash(npm install -g @vercel/before-and-after)
  - Bash(*/upload-and-copy.sh *)
  - Bash(curl -s -o /dev/null -w *)
  - Bash(gh pr view *)
  - Bash(gh pr edit *)
  - Bash(vercel inspect *)
  - Bash(vercel whoami)
  - Bash(which vercel)
  - Bash(which gh)
---

# Before and after

Capture a matching pair of screenshots that shows a UI change, and deliver the pair where the task
needs it.

The npm package is `@vercel/before-and-after`. With `npm` and `npx`, always use that full name. The
npm package named `before-and-after` is a different package.

## Rules

- Do not switch branches or stash another task's changes.
- Never run the baseline and the changed app at the same time on this machine. They share its ports
  and its database. See "Get the before state".
- Use `--full` only when the user explicitly asks for a full-page or full-scroll capture.
- Use `--markdown` when the user wants PR integration or Markdown output.
- Use `--mobile` or `--tablet` when the user mentions a phone, mobile, tablet, or responsive layout.
- Reuse the before captures, baseline URLs, and revision information that the task already has.
  Confirm that they show the relevant behavior and match the after capture's viewport and starting
  state.
- Treat the current state as the after only when the task context establishes it. If the before
  state is still ambiguous after you check the available context, ask for the missing baseline. Do
  not ask again for a URL when a valid image pair or an earlier baseline is already available.

## Get the before state

Each task runs on its own machine, with one checkout. Get the before in this order:

1. **Captured at the start.** The `new-feature` skill takes before screenshots while the checkout is
   still on fresh `main`, before any edit. Reuse them.
2. **A deployed baseline.** If production or staging runs `main`, use its URL as the before. Check
   access first.
3. **A temporary clone, one server at a time.** Use this only when the task allows a baseline
   server:
   1. Stop the changed app's dev server.
   2. Run `git clone --depth 1 --branch main <repo-url> /tmp/baseline-<task>`, install, and start
      the app on the **same port**. Capture the before.
   3. Stop it, delete `/tmp/baseline-<task>`, and start the changed app again. Capture the after.

   **Database:** if the branch added migrations, the old code can fail against the migrated
   database. Give the baseline its own database (Rails: a separate `DATABASE_URL`, then `bin/rails
   db:prepare`), or skip the before and say why. Never roll back migrations on the shared database.

If none of these works, ask the user for the before images or a baseline URL.

## Capture and deliver

1. Use an installed `before-and-after` CLI, or `npx @vercel/before-and-after`.
2. For remote URLs, check access when needed. A 401 or 403 indicates protection. An existing image
   pair needs no URL and no access check.
3. Capture the missing images with `before-and-after "<before-url>" "<after-url>"`.
4. When the task calls for uploaded evidence or PR Markdown, run `before-and-after before.png
   after.png --markdown` once. For a local capture request, deliver the files without uploading
   them.
5. Append the Markdown to the PR when PR integration is part of the task.

Resolve bundled script paths relative to this skill's folder, not the project's working directory.
Reuse earlier evidence; do not capture it again.

## Command reference

```bash
# Basic usage
before-and-after <before-url> <after-url>

# With a selector
before-and-after url1 url2 ".hero-section"

# A different selector for each
before-and-after url1 url2 ".old-card" ".new-card"

# Viewports
before-and-after url1 url2 --mobile    # 375x812
before-and-after url1 url2 --tablet    # 768x1024
before-and-after url1 url2 --full      # full scroll

# From existing images
before-and-after before.png after.png --markdown

# Through npx (use the full package name)
npx @vercel/before-and-after url1 url2
```

| Flag | Description |
| --- | --- |
| `-m, --mobile` | Mobile viewport (375x812) |
| `-t, --tablet` | Tablet viewport (768x1024) |
| `--size <WxH>` | Custom viewport |
| `-f, --full` | Full scrollable page |
| `-s, --selector` | CSS selector to capture |
| `-o, --output` | Output directory (default: ~/Downloads) |
| `--markdown` | Upload the images and print a Markdown table |
| `--upload-url <url>` | Custom upload endpoint (no default: see "Upload images") |

## Upload images

Nothing uploads by default, because screenshots of a private app must not become public by accident.
Uploading needs a host that the user chose on purpose. Ask the user before you upload.

```bash
# 0x0.st: public, no signup. Only when the user agrees that the images may be public.
IMAGE_ADAPTER=0x0st ./scripts/upload-and-copy.sh before.png after.png --markdown
```

## Vercel deployment protection

If a `.vercel.app` URL returns 401 or 403:

1. Check for the Vercel CLI: `which vercel && vercel whoami`.
2. If it is available, run `vercel inspect <url>` to get a bypass token.
3. If it is not, ask the user to provide a bypass token, take manual screenshots, or disable the
   protection.

## Add the comparison to a PR

```bash
# Check for the gh CLI
which gh

# Get the current PR
gh pr view --json number,body

# Write the existing body plus the comparison to a temporary file, then:
gh pr edit <number> --body-file /path/to/pr-body.md
```

If there is no `gh` CLI, print the Markdown and tell the user to paste it manually.

## Errors

| Error | Fix |
| --- | --- |
| `command not found` | `npm install -g @vercel/before-and-after` |
| `could not determine executable` | Use `npx @vercel/before-and-after` (the full name) |
| 401 or 403 on `.vercel.app` | See "Vercel deployment protection" |
| Element not found | Verify that the selector exists on the page |
