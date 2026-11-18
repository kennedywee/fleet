# Writing explanations readers can follow

Use this guidance for blog-style explanations. Preserve the form of an explicitly requested spec, checklist, or reference document.

## Reference observations

These are writing references, not page designs or technical authorities for unrelated tasks:

- [Flavio Copes: celld](https://flaviocopes.com/celld/) builds from a familiar problem to a small mental model, then follows a request. Short paragraphs introduce terms before relying on them. Concrete applications make the architecture useful to the reader; limitations sit near the claims they qualify.
- [Shopify: scaling inventory reservations](https://shopify.engineering/scaling-inventory-reservations) starts with the consequences of failure for a buyer and merchant. It connects engineering choices to specific constraints, observations, and costs, then shows how investigation changed the team's understanding.

Apply these general techniques in original language. Do not copy distinctive phrasing, imitate an author's identity, or invent personal experience. Reading these articles again is unnecessary for routine use; consult current primary sources for the actual topic's facts.

## Build a connected explanation

Infer the audience and the question from the request. For a developer audience, explain unfamiliar domain concepts without reteaching basic programming. Open with the central answer and enough context to understand why it matters.

Pick a concrete example that can carry the explanation. Track the same request, record, user, or file as the mechanism unfolds. Give it stable names. Say who acts, what changes, and why that permits or prevents the next step. Explain necessary terminology at first use, rather than requiring the reader to consult a glossary.

For a decision, connect the constraint to the chosen mechanism and its consequence. State a tradeoff where it changes the reader's judgment. For an investigation, separate what was observed from what was suspected and what was later established. Do not invent failed attempts or measurements to create a story.

Use headings that identify an actual question or claim, such as “When is it safe to delete the local file?” Each paragraph should advance that answer. Link paragraphs through their subject and reasoning; avoid an article made of disconnected one-line assertions. Vary sentence length naturally, use concrete verbs, and avoid promotional language.

Use code only when the reader needs to see the operation or API shape. Explain what to notice and what the snippet leaves out. Use a table when several options share comparable dimensions. A diagram complements the explanation; it must not hide a missing causal step.

End with the implication for this reader: when the approach fits, its relevant limits, or the decision supported by the evidence. Do not repeat the entire article as a generic conclusion.

## Example: turn a checklist into an explanation

Checklist: “Upload. Verify. Delete. Return URL.”

Explanation:

> An upload can finish before we know the public copy is usable. Suppose we have generated `report.html`. The uploader returns a URL, but that response alone does not show that a reader can retrieve the same file.
>
> We download the returned URL into a separate temporary file and compare its bytes with `report.html`. A failed download or a mismatch leaves the local files intact, so the report is still available for recovery. Once the files match, we delete the generated HTML and its temporary previews, then return the public link.

The example adds the reason for verification and traces both outcomes. Keep the prose proportional to the actual question; do not stretch every four-step process into an essay.

## Editing pass

Read the prose without its visual styling. Can the intended reader explain the mechanism back, including the condition that makes it work? Remove unexplained terminology and repeated claims. Put sources beside factual claims. Label hypothetical examples and estimates, and keep qualifications close to the results they limit.
