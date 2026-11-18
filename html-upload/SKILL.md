---
name: html-upload
description: Publish completed HTML artifacts, reports, diagrams, and previews to Kennedy's HTML host and return an unlisted public URL. Use when the user wants an HTML file uploaded, hosted, or shared through html.kennedywee.com, or invokes html-upload. Not for deploying applications or publishing artifacts requested to remain local or private.
---

# HTML upload

Publish a local artifact through the installed `html-upload` CLI. The service uses one permanent
Cloudflare Worker and R2; publishing a file does not require Wrangler, deployment, or Cloudflare
account credentials.

## Publish

1. Finish the intended HTML file. Local checks or visual previews are optional when useful or
   requested. Prefer a self-contained file when practical. The default size limit is 10 MiB per
   file.
2. Use `html-upload <file> --quiet`, capturing stdout, stderr, and the exit status. Use an absolute
   file path when the working directory is uncertain.
3. On exit status `0`, stdout is the complete URL followed by a newline. Capture it unchanged. Never
   shorten it, remove its date/time folders, or reconstruct it from the filename. Clipboard support
   is optional and does not affect upload success.
4. For generated HTML, complete the cleanup workflow below before returning the URL as a clickable
   link. Original project files and user-supplied source files are retained; the CLI's default
   behavior must remain unchanged.

If the user already authorized publication, proceed without another confirmation. Publish only the
intended artifact and necessary assets. Respect requests for local-only or private output: this
service is **unlisted, not private**, and anyone with the URL can access it. Do not include
credentials or unrelated private data.

## Deliver and clean up generated HTML

For HTML generated for delivery, use this order: **upload → delete generated local HTML and
temporary previews → return the exact public URL**. This is an agent workflow, not automatic CLI
deletion. Explicit requests to keep local files take precedence.

- Exit status `0` with a complete URL is successful publication. Return the CLI's exact URL as a
  clickable link. No hosted verification is required.
- The host blocks automated agents. Do not fetch, browse, screenshot, or compare the hosted page or
  assets after an upload, including after `--replace`. Do not retry uploads, change hosts, or bypass
  bot protection to verify content. Do not label a successful upload as unverified because the
  hosted page was not checked.
- Local file checks and visual previews are optional when useful or requested. Perform them before
  upload and cleanup if desired; they are not a condition of delivery.
- Track the exact generated HTML and temporary preview paths created for the current artifact,
  including screenshots and preview copies. Never infer that a file is disposable merely because it
  is HTML or lives in a temporary directory. Original project files, user-supplied source files, and
  unrelated files must remain.
- For multi-file output, finish every required upload before any cleanup.
- Once all uploads succeed, delete only the generated local HTML and temporary preview files tracked
  for this artifact. Use exact paths, not globs or recursive cleanup of shared directories. Confirm
  deletion locally.
- If uploading fails, is unavailable, or has an uncertain result, retain the local HTML and
  temporary preview files and report the failure with the local path. Follow the retry limits below.
  Do not present an uncertain upload response as successful publication.
- If cleanup fails after a successful upload, return the upload URL and report the local files that
  remain. Do not claim cleanup completed.

## Configuration on this machine

Use `HTML_HOST_URL` and `HTML_HOST_TOKEN` from the execution environment when they are already
configured. For this production installation, a trusted owner-only file provides both values:

```bash
(
  set +x
  source "$HOME/.config/html-upload/production.env"
  html-upload /tmp/report.html --quiet
)
```

Run this in Bash. The subshell keeps credentials out of the caller's persistent environment. Do not
override an explicitly requested alternative host with this production configuration.

Never print or read the credential file into tool output, enable shell tracing around it, place the
token in command-line arguments, or embed it in HTML. Load it directly into the process environment.
If credentials are unavailable, report the missing configuration; do not rotate the production
secret or use the development token.

If `html-upload` is missing from PATH, this installation's executable is
`/home/kennedywee/Work/kennedywee/html-upload/bin/html-upload`. On another machine, locate the
checkout and use `bin/html-upload` or install with `npm link` from that checkout. Node.js 24 or
newer is required. The production credential file must be provisioned separately; it is not in the
repository.

## Names and assets

- Choose a short, descriptive, lowercase hyphenated filename, usually two to four meaningful words:
  `timetable-strategy.html`, `timetable-strategy-animated.html`, or `timetable-research.html`. Avoid
  redundant words and suffixes such as `final`.
- Do not append the upload date or time to the filename; the folders already provide it. Include a
  date only when needed to identify the content, such as a reporting period, or when explicitly
  requested. Preserve user-required filenames and relative asset references.
- `--name timetable-strategy.html` selects the hosted filename without renaming a source file. The
  CLI does not infer titles or strip dates.
- Omit `--folder` for a new artifact. The server uses UTC `YYYY-MM-DD/HHmmss`. An existing key gets
  a short suffix on the time folder (`HHmmss-2` through `HHmmss-10`); exhausted slots return `409`.
  Different filenames may share a time folder. These URLs are predictable, publicly readable, and
  unlisted; they do not provide secrecy.
- For a small multi-file page, upload `index.html` first, take the entire date/time folder from its
  returned URL, including any collision suffix, then upload its CSS, JavaScript, and images using
  `--folder <that-folder>`. Preserve the page's relative filenames. Nested asset folders are
  supported.
- Return the exact `index.html` URL after all necessary uploads succeed and, for generated HTML,
  cleanup completes (or any cleanup failure is reported). A directory URL needs a trailing slash for
  relative links.
- To edit an already published artifact, use `html-upload <file> --replace <url> --quiet` with the
  exact URL previously returned. The URL stays the same and the file must already exist. Use it only
  when the user asks to edit or replace a published file; otherwise publish revisions to a new
  generated folder. Return the exact URL after a successful replacement without fetching it. Cached
  copies can stay for up to an hour. `--replace` cannot be combined with `--name` or `--folder`.
- Reusing a folder and filename with `--folder`/`--name` also overwrites that object, but creates it
  if missing; prefer `--replace` for edits.

## Failures and DNS fallback

A nonzero exit status is a failed CLI operation. Report the useful stderr message without
credentials; never present partial output as a successful publication. Check missing
files/configuration, `401` credentials, `413` file limits, `409` occupied date/time paths, or `403`
Cloudflare protection as indicated. Do not change account-wide bot settings to resolve a single
upload failure.

If `html.kennedywee.com` cannot resolve **before starting an upload**, this same service also
accepts uploads at `https://kennedy-html-host.kennedyweesupitang.workers.dev`. For this production
installation only, use a per-command override after loading credentials:

```bash
HTML_HOST_URL=https://kennedy-html-host.kennedyweesupitang.workers.dev \
  html-upload /tmp/report.html --quiet
```

The returned public URL still uses `html.kennedywee.com`; return it unchanged. This fallback avoids
modifying system DNS or persistent configuration. Do not substitute a different hostname for other
explicitly configured services.

After a timeout, connection interruption, or malformed success response, the upload may already
exist. Stop and report the uncertainty rather than retrying automatically and creating duplicate
objects. Deleting hosted artifacts, deleting original local files, overwriting existing artifacts
(except an explicitly requested `--replace`), token rotation, and infrastructure changes require
their own task scope; ordinary publishing does not imply them. The generated-local-file cleanup
explicitly described above is part of this publishing workflow.

The host sends anti-indexing, no-referrer, and nosniff headers and rejects common crawler
User-Agents. These measures do not provide read authentication. Arbitrary HTML and external scripts
execute normally in visitors' browsers; no restrictive CSP is added.
