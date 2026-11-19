---
name: evidence-driven-testing
description: Record visual proof while you test changed behavior hands-on, then post the video and a results summary where the task needs it. Use when changed runtime behavior needs observable verification, including headless environments (scripted screenshots and probes) and non-UI changes (measured numbers, output pairs).
---

# Evidence-driven testing

Record proof of behavior and deliver it to the requested destination.

Choose evidence in proportion to the change:

- **Interactive flows:** the recorder.
- **Headless UI checks:** scripted captures.
- **CLI or API changes:** output pairs.
- **Documentation-only edits:** content checks and verification of runnable examples. No recording.

If the project has a `verify-<app>` skill, follow it to launch and drive the app, and to learn what
proves each feature. This skill then covers how to record and post that proof. If the project has
none and you need one, use the `create-verification-skill` skill.

Reuse suitable evidence that the task already captured. Publish only to destinations that the
requested work includes.

## What the recording is

The recording captures you testing the app through computer use. Start the recorder, then drive the
app yourself through each test target: click, type, navigate. Every action in the video is the test,
performed live. The recording has no value as evidence unless it shows that interactive session.

If the harness has no computer-use tools but a GUI exists, drive the app with `cua-driver` (see
"Drive with cua-driver"). It is still your live session.

## Inputs

- **Test targets** (required): the behaviors or flows to verify, phrased as testable statements.
- **PR or issue** (optional): where to post the evidence. If omitted, deliver to the requester only.

## The recorder

The bundled recorder is `scripts/evidence.py`. It captures the display with FFmpeg on Linux, macOS,
and Windows. It timestamps each annotation that you add while testing, burns the annotations into
the video on stop, and verifies the result with ffprobe. It writes `evidence.mp4`, `report.md`, and
`manifest.json` into the session folder.

`EVIDENCE` below means the path to `scripts/evidence.py` inside this skill's folder, wherever the
skill is installed. Example: `~/.claude/skills/evidence-driven-testing/scripts/evidence.py`.

### Check first

Run `python3 $EVIDENCE doctor`. It verifies `ffmpeg`, `ffprobe`, `libx264`, and the `ass` filter
(`ready`). Then it reports which screen-capture source works on this machine (`capture_ready`, and
the source that `auto` will pick). It exits non-zero only when the toolchain is missing, so read
`capture_ready` before you record.

### Platforms

`--source auto` picks the first available source.

| OS | Source | Needs |
| --- | --- | --- |
| Linux X11 / XWayland | `x11` (x11grab) | `DISPLAY` set |
| Linux Wayland | `wayland` (wf-recorder) | `WAYLAND_DISPLAY` set, `wf-recorder` on PATH, and a compositor confirmed to support wlr-screencopy: a known wlroots one (Sway, Hyprland, river, Wayfire, labwc, dwl, niri) or one verified with `wayland-info`. GNOME and KDE Wayland cannot be captured this way, and `doctor` says so. Use `x11` through XWayland for X11 apps, or a fallback recorder. `--source wayland` still forces it |
| macOS | `avfoundation` | Screen Recording permission granted to the terminal or agent host app. `doctor` lists the screen indexes for `--screen-index` |
| Windows | `gdigrab` | Any standard ffmpeg build, and `powershell` for process checks |

The capture is the full screen by default. `--geometry WxH` and `--offset X,Y` crop a region on x11,
wayland, and gdigrab. XWayland sees only X11 windows, so prefer the `wayland` source when the app
under test is Wayland-native.

### Crash-safe raw capture

The raw recording is MPEG-TS (`raw.ts`). If the recorder is killed hard or crashes, what it captured
still probes and renders. `stop` remuxes or re-encodes it into a standard `evidence.mp4`.

### How stopping works

On Linux, `stop` signals the recorder through a pidfd.

On macOS and Windows, and on Linux when the kernel or a seccomp policy refuses pidfds, `start`
launches a small supervisor process that owns the ffmpeg child. `stop` asks the supervisor, through
`stop.request` in the session folder, to interrupt, then terminate, then kill. The supervisor writes
`recorder-exit.json` when it is done.

Nothing ever signals a bare PID, so a recycled PID cannot be hit.

- If the supervisor dies while the recorder still runs, `stop` refuses and tells you which PID to
  stop by hand.
- If the supervisor died before it could record which process it started, `stop` stays blocked.
  Check for a stray recorder yourself, then run `stop` again with `--accept-untracked-recorder`. The
  report then carries that caveat.

### Fallback recorders

Use a fallback when `doctor` reports no capture source, for example on Wayland without wf-recorder:

- `cua-driver recording start <dir>` and `cua-driver recording stop` (see "Drive with cua-driver");
- the OS recorder (macOS: `screencapture -v out.mov`).

These paths have no annotation overlay, so keep the annotation protocol as files. Write an
`assertions.md` that lists each `setup`, `test_start`, and `assertion` with its result and the
approximate video timestamp, exactly as in the headless path.

### Never use the test source as evidence

Never present `--source test` (the synthetic pattern generator) as UI evidence. It exists to
smoke-test the toolchain. The repo's `tests/test_evidence.py` exercises it.

## Steps

### Prepare the screen

- Maximize the browser or app window. Close popups, notifications, and extra panels.
- Navigate to the starting state (logged in, correct page) before you record, unless the setup
  itself is under test.
- Note the exact revision under test: `git rev-parse HEAD` and `git branch --show-current`, or the
  deployment URL. The recorder stamps them into the report.

### Start recording

Begin the screen recording before the first meaningful action:

```bash
python3 $EVIDENCE start \
  --output .artifacts/<task-name> \
  --title "<what is being verified>" \
  --commit "$(git rev-parse HEAD)" --branch "$(git branch --show-current)" \
  --environment "<OS / browser / display / deployment>"
```

It prints JSON with a `session` path and the chosen `source`. Keep the path (`SESSION=...`) for
every later command.

The source is detected automatically and the whole screen is captured. Pass `--source`,
`--geometry`, `--offset`, `--display` or `--xauthority` (X11), `--screen-index` (macOS), or
`--output-name` (Wayland) only when `doctor` or the situation calls for it.

Then add a `setup` annotation that describes the starting context:

```bash
python3 $EVIDENCE annotate "$SESSION" --type setup \
  --message "Logged in, navigating to connectors page"
```

### Test through computer use, and annotate as you go

Perform every interaction through computer use on the live app. The recording captures your session,
so the testing and the evidence are the same act. Work at a watchable pace: let the UI settle after
each action, so state changes are visible on video.

At the start of each named test, add a `test_start` annotation in Jest style:

```bash
python3 $EVIDENCE annotate "$SESSION" --type test_start \
  --message "It should execute the tool directly when permission is 'always'"
```

After each check, add an `assertion` annotation with `--result passed`, `failed`, or `untested`:

```bash
python3 $EVIDENCE annotate "$SESSION" --type assertion --result passed \
  --message "Tool ran without a permission prompt"
```

Rules for assertions:

- Write one assertion per meaningful state change. Consolidate; do not annotate each UI label.
- Use "Precondition: ..." assertions to establish the starting state.
- Keep each message under 80 characters and high-signal. The recorder rejects longer messages.
- If a test cannot run (a missing prerequisite, an expired auth window), mark it `untested` with the
  reason. Never skip silently.
- The timestamp records when you asserted, not whether the assertion was true. Look at the screen
  before you choose `passed`.

### Stop and review

Stop recording after the final assertion:

```bash
python3 $EVIDENCE stop "$SESSION"
```

`stop` ends the capture gracefully, so the recorder flushes. It escalates only if the recorder
ignores the request. Then it burns the annotations into `evidence.mp4`, probes the result, and
writes `report.md` and `manifest.json` next to it. It prints `"verified": true` on success.

- **Rendering fails:** the session is marked `finalization_failed`. Fix the reported cause and run
  `stop` again. A retry does not signal the recorder twice.
- **The recorder can no longer be signalled safely** (it died, or its PID now belongs to another
  process): the session is marked `recorder_lost`. Running `stop` again finalizes the captured
  video, but only once that recorder process is confirmed gone. If it is still alive, stop it first.
  Otherwise the video would be rendered while it is still being written.

Before you share the recording, confirm that it captured the key moments. Extract a frame at each
assertion timestamp (`ffmpeg -ss <t> -i evidence.mp4 -frames:v 1 frame.png`) and check that the
state and the label are visible.

Fill in the Caveats section of `report.md`. Never leave the placeholder.

### Post the evidence

- `report.md` is the report: what was tested, the environment and exact commit, pass or fail per
  test, and caveats. Extend it; do not rewrite it from scratch.
- Post the video and the summary as a PR comment. If it is your PR, embed them in the PR
  description. Attach the video with `gh`: `gh pr comment <number> --body-file summary.md --attach
  .artifacts/<task-name>/evidence.mp4`, or the same `--attach` flag on `gh pr edit`. Then read the
  comment or description back, and confirm that it holds the uploaded asset before you claim it is
  posted.
- If the task includes a tracker issue and posting there is authorized, attach the same video with a
  one-line result.
- Send the report and the recording to the requester.

## Guardrails

- The video must show the actual test session, driven live. Never present scripted playback,
  stitched clips, or synthetic footage as a recording. If the harness lacks computer-use tools but a
  GUI exists, drive through `cua-driver`. With no GUI at all, use the headless path.
- Never record a half-covered or tiled window. Maximize it first.
- Never record a screen that shows secrets, tokens, customer data, or payment details. If a flow
  requires them, mark it `untested` and say why.
- When you verify a fix, show or reference the old failure next to the new success.
- Always state the exact commit, branch, or deployment that you tested.

## Drive with cua-driver

Use this path when a display exists but you have no built-in computer-use capability.
[cua-driver](https://github.com/trycua/cua) (macOS, Windows, Linux) is the actuator. It is still you
testing the app live. The recording rule holds unchanged; only the input mechanism differs.

- Verify the setup with `cua-driver doctor` before you record. If a `cua-driver` skill is installed,
  read it and follow its protocol. The snapshot-before-action invariant is mandatory.
- Loop per interaction: `launch_app` → `get_window_state` (accessibility tree and screenshot) → act
  through `element_token` (`click`, `type_text`, `press_key`) → `verify_state` for the expected
  postcondition. Each `verify_state` check maps one-to-one onto an `assertion` annotation.
- Wherever `doctor` reports `capture_ready: yes`, keep using the bundled recorder for the video and
  the annotations. cua-driver supplies only the input.
- Otherwise, `cua-driver recording start <output-dir>` and `cua-driver recording stop` are the
  recorder. The output directory is required, and the daemon must be running (`cua-driver serve`).
  Video capture is on by default and is finalized to `<output-dir>/recording.mp4` on stop. On
  Windows and Linux it shells out to ffmpeg, so a missing ffmpeg or display yields only the per-turn
  trajectory folders (before and after screenshots, `action.json`, `click.png`) and no video.
- After you stop, verify that `recording.mp4` exists before you cite it. If it is absent, fix the
  recorder, or present the per-turn before and after screenshots as numbered captures, as in the
  headless path.
- If no annotation overlay is available on this path, keep the protocol as files: an `assertions.md`
  that lists each `test_start` and `assertion` with its result, exactly as in the headless path.

## Headless path

Use this path when there is no desktop to record. Keep the same assertion discipline, and replace
the recorder with scripted capture.

Save everything to `.artifacts/<task-name>/`, and gitignore it: evidence is uploaded, never
committed. Keep the capture script beside the captures, so the run is repeatable.

### Screenshots

The `before-and-after` CLI (`@vercel/before-and-after`) captures URLs or elements. The
`before-and-after` skill attaches the pairs to the PR. In containers and VMs where Chrome fails with
"No usable sandbox", set `AGENT_BROWSER_ARGS="--no-sandbox"`.

### Video and multi-step flows

Use a one-off Playwright script. Run it without adding playwright to the project's dependencies:

```bash
bash /path/to/evidence-driven-testing/scripts/run-playwright.sh record.mjs
```

The helper does this:

- It installs the pinned Playwright version from its bundled manifest and lockfile, with `npm ci` in
  a temporary directory.
- It copies the script beside that installation, installs Chromium if needed, and removes the
  temporary directory on exit.
- It keeps the caller's working directory, so relative artifact paths still point into your project.

Keep the script self-contained: relative imports and adjacent data files are not copied. For scripts
with local imports, use the project's existing Playwright setup. The browser cache stays available
for later runs.

`npx --package=playwright` adds executables to PATH. It does not make the package importable from an
arbitrary ESM script. A minimal `record.mjs`:

```js
import { chromium } from "playwright";
const browser = await chromium.launch();
try {
  const context = await browser.newContext({
    recordVideo: { dir: ".artifacts/<task-name>/" },
  });
  try {
    const page = await context.newPage();
    await page.goto("http://localhost:3000/path-under-test");
    // Drive the flow and check each expected state here.
  } finally {
    await context.close(); // Finalizes the video even if an assertion fails.
  }
} finally {
  await browser.close();
}
```

Trim or compress the file with ffmpeg if it is large.

When you upgrade the capture tooling, update `scripts/playwright/package.json`, regenerate its
lockfile with npm, and run the capture checks again.

### The annotation protocol becomes files

Number the captures in test order, with the assertion in the name: `01-precondition-signed-in.png`,
`02-it-saves-on-blur-passed.png`. Keep an `assertions.md` in the artifacts folder that lists each
`test_start` and `assertion` with its result (`passed`, `failed`, or `untested` with the reason).

## Non-UI changes still need evidence

- **API and performance:** a scripted probe with measured numbers (request counts per phase, latency
  before and after), captured to `probe-output.txt`.
- **Rendering, canvas, and shaders:** rendered frames plus pixel assertions (diff values), reviewed
  by eye and saved as PNGs.
- **Agent behavior:** the relevant transcript excerpt that shows the tool call and the response.
- **Bug fixes:** reproduce and capture the failure **before** you write the fix. That capture is the
  before half of a before and after pair.

## Capture hygiene

- Confirm that the server you probe runs your code (the right port, the right process), especially
  when several agents share a machine. Use `lsof -i :<port>`. Where `lsof` is not installed, use `ss
  -ltnp "sport = :<port>"` to find the listener's PID, then `ps -p <pid> -o args=` to confirm that
  it is yours.
- Evidence adds to the repo's checks (typecheck, build, tests). It never replaces them.
- Use the `before-and-after` skill to put before and after image pairs in the PR.

## Requirements

- **Recorder path:** a GUI environment that you can drive, with built-in computer use or the
  `cua-driver` CLI ([trycua/cua](https://github.com/trycua/cua)), plus an authenticated browser
  session for the app under test.
- **Bundled recorder:** Python 3, and `ffmpeg` and `ffprobe` built with libx264 and the `ass`
  filter. It runs on Linux (X11 through x11grab, Wayland through wf-recorder), macOS (avfoundation,
  with Screen Recording permission), and Windows (gdigrab).
- **Headless helper:** Bash, Node 20+, npm, and the Chromium system libraries. It installs
  Playwright outside the target project.
- **Posting evidence:** `gh` (the GitHub CLI) or an equivalent.
