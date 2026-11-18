# Visuals that explain one relationship

[HumanLayer's
show-me](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md)
selects a compact representation for the question: logic, runtime calls, component ownership, file
structure, interactions, or a change. It keeps relevant context and places the visual beside
supporting text. Adapt that selection principle to an article; the article still needs connected
prose.

## Choose the representation

| Reader needs to understand | Useful representation |
| --- | --- |
| A conditional path and its outcomes | Flowchart with labelled decisions |
| Messages between participants over time | Sequence diagram |
| Valid states and the events changing them | State diagram |
| Who calls or contains what | Shallow call/component tree |
| How a design changes | Comparable before/after views or a focused diff |
| Several choices on the same dimensions | Table |
| An algorithm's exact rules | Pseudocode |

A straight three-step action may need only a sentence or ordered list. Choose a figure because it
resolves a reader's question, not because every section needs an illustration.

## Draw the actual mechanism

Use the same names as the prose and evidence. Start where the example starts and end at its
meaningful outcome. Name actions precisely; label arrows when their payload, event, or condition
matters. Distinguish a data transfer from a control decision. Show a waiting point, failure branch,
retry, or ownership boundary when omitting it would misrepresent the claim. Do not invent behavior
to make the diagram symmetrical.

Keep the main path easy to follow. Put exceptional paths to one side, avoid crossing connectors and
overlapping labels, and split an overloaded figure into an overview and a focused detail. Keep node
spacing, alignment, arrowheads, and label hierarchy consistent. Use color sparingly to encode
meaning, with text or shapes providing the same information.

Place the figure where the prose needs it. Introduce the question it answers and add a caption
identifying the important consequence. Do not merely restate every node in the caption.

## Render for standalone HTML

Use an available local Mermaid renderer for graph layout when suitable, then embed the resulting
SVG. Check tool availability before choosing it. If no renderer is installed, a small inline SVG or
semantic HTML/CSS diagram is sufficient; do not install a tool merely to draw a few boxes.

Use installed visualization tooling for a parameter explorer or step-through explanation only when
interaction helps answer the question. Its result must work inside the delivered self-contained
file. A chat widget, Markdown Mermaid fence, external runtime, or screenshot of unreadable code does
not satisfy HTML delivery.

Provide an SVG title/description and a prose equivalent of the essential relationship. Keep labels
readable on mobile; simplify or reorient a wide graph rather than shrinking its text. Let the
surrounding article remain useful if scripts are disabled. Any optional animation must respect
reduced motion.

Inspect rendered figures for clipped labels, wrong arrow direction, missing conditions, and
misleading timing. Trace the article's example through the diagram and compare each transition with
the source facts. A polished diagram with incorrect behavior fails review.
