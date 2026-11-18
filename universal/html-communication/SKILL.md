---
name: html-communication
description: Create standalone HTML explanations, plans, reports, comparisons, and UI mockups with clear blog-style writing and focused diagrams, then publish through html-upload and return an accessible link. Use for HTML writeups of work, not HTML that ships as part of a product.
---

# HTML Communication

## When to use

Use this skill when the user wants a plan, spec, write-up, findings, summary, report, comparison, or set of UI mocks presented as readable HTML.

Do not use it for HTML that ships as part of a product.

## Explanation first

For explanatory documents, read [references/explanation.md](references/explanation.md) before drafting. Default to a technical blog article: connected prose that teaches the reader how something works and why the details matter. An explicitly requested spec, checklist, or short brief keeps its requested form.

Start with the reader's question and a concrete situation. Establish the essential idea, then follow an example through the mechanism, explain the important decisions, and discuss evidence and limits. This is a useful progression, not a mandatory set of headings. Match depth to the audience; do not impose the chat response length limit on the article.

Draft the explanation before choosing its layout. Use paragraphs for reasoning, lists for parallel facts, and tables for genuine comparisons. Do not turn each paragraph into a card, replace causal explanations with bullet summaries, or add sections merely to fill a template. Retain the installed design skills for presentation; the reference articles guide writing, not visual styling.

## Visual explanations

When a relationship is easier to see than describe, read [references/visual-explanations.md](references/visual-explanations.md). It adapts the visual-selection approach from HumanLayer's `show-me`; it is self-contained and does not require installing that skill.

Choose a flowchart for branching, a sequence diagram for exchanges over time, a state diagram for lifecycle changes, or a compact tree/diff for code structure and changes. Use a visualization tool when it improves comprehension. Introduce each figure in the surrounding prose and explain the consequence the reader should notice.

For published HTML, render diagrams into inline SVG or semantic HTML/CSS. Mermaid is an authoring option when a local renderer is available; raw Mermaid text is not a rendered diagram. Do not add CDN scripts or depend on a chat-only visualization runtime. Use interaction only when changing a parameter or stepping through a process materially explains behavior; always retain a readable static explanation.

## Design

Before creating or substantially revising the HTML, load and apply both installed design skills:

- `impeccable` (listed as `impeccable:impeccable` in some environments): use its **Read** mode for documents, and the appropriate surface mode for UI mocks. Follow its relevant design and craft guidance for hierarchy, typography, spacing, and visual polish.
- `ui-ux-pro-max`: use its search workflow to select a coherent visual direction for a new document, or a targeted query for a revision. Apply relevant typography, palette, responsive layout, accessibility, and chart guidance. Inspect search results for suitability before using them.

Resolve these skills from the active agent's skill catalog or skill directory; resolve scripts and references relative to the loaded skill. In Claude, use `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`. Do not hardcode versioned plugin-cache paths. If a dependency is missing, report it and continue with the available guidance without claiming it was applied.

Keep the result appropriate to the content: a readable editorial document with deliberate typography, consistent spacing, restrained color, and useful diagrams or tables. Preserve the user's requested aesthetic and any established design. Apply design workflows to the standalone artifact; keep any supporting design files beside the artifact rather than modifying unrelated product files.

## Document

Create one self-contained HTML file, capped at 512 KB. Choose a short, descriptive, lowercase hyphenated filename, such as `timetable-strategy.html` or `timetable-research.html`. Do not append the upload date or time; html-upload supplies date/time folders. Include a date only when needed to identify the content (for example, a reporting period) or explicitly requested. Use meaningful variant suffixes such as `-animated` rather than repeating dates or adding `final`.

- Use a readable article layout for explanations, with headings that follow the argument. Avoid promotional heroes, decorative chrome, marketing voice, and em dashes.
- Make it mobile-readable with a responsive viewport and no fixed-width layout. Keep wide tables and code blocks from overflowing the page.
- Use semantic HTML, inline CSS, inline SVG, and HTTPS or data-URL images. Prefer embedded assets and system font stacks for portability.
- Use an inline classic script only when interactivity materially helps. Keep scripted pages useful without JavaScript. Avoid storage and network dependencies; the public HTML host does not supply a restrictive script sandbox.
- Give external links `target="_blank"` and `rel="noopener noreferrer"`.
- Provide readable contrast, visible keyboard focus, and text labels for charts or controls; do not rely on color alone.

Never include external or module scripts, inline event handlers, `javascript:` URLs, forms, frames, embed, objects, applets, meta refresh, linked stylesheets, secrets, private URLs, or local filesystem paths.

## UI Mocks

When the user asks for variants:

- Render real styled variants, not descriptions.
- Label them `A`, `B`, `C`... for easy selection.
- Lay them out for direct comparison.
- Keep one local file during drafting and review. After a successful upload, delete it as described below. Publish revisions under a new generated URL unless replacement was requested.

## Check and deliver

1. Review the explanation, diagrams, and source evidence locally. Visual verification is optional: use local previews at desktop and mobile sizes when useful or requested. Do not make browser rendering a condition of delivery. Fix any defects found in local checks.
2. Load and follow the installed `html-upload` skill. Publishing the completed artifact is the default delivery workflow authorized by this skill's user preference; do not ask for confirmation again. An explicit local-only or private request overrides this default. The host is unlisted, not private: anyone with the URL can read the artifact. Do not publish confidential content without authorization to share it that way.
3. Use `html-upload`'s documented credential loading, CLI, and failure handling. Do not deploy infrastructure or copy credentials into the artifact. If the skill is missing, report that publishing is blocked rather than inventing an upload procedure.
4. Upload the completed file and capture the exact returned URL. Exit status `0` with a complete URL is successful publication. The host blocks automated agents, so do not fetch, browse, screenshot, or compare hosted content. Do not make hosted verification a condition of delivery or label a successful upload as unverified. For multi-file output, finish every required upload before cleanup.
5. After all uploads succeed, delete the generated local HTML and temporary preview files created for this artifact. Track these exact paths while working; do not use broad directory cleanup or delete original project files, user-supplied source files, or unrelated files. This cleanup is the final publishing operation, performed by the agent; keep the CLI's default behavior unchanged. Explicit requests to keep local files take precedence.
6. Return the exact URL produced by the CLI as a clickable Markdown link, such as `[Open the report](<exact returned URL>)`. The hosted link is the primary deliverable; a local file path alone is insufficient. Never invent or reconstruct the URL. If cleanup fails, return the upload URL and report which local files remain; do not claim deletion succeeded.
7. If uploading fails, is unavailable, or has an uncertain result, retain the local HTML and temporary preview files, report the failure or uncertainty, and provide the local path. Follow `html-upload`'s retry limits. An uncertain upload response must not be presented as completed publication.
