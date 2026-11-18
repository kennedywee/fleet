---
name: leaving-pr-comments
description: Format and check a comment that you post on GitHub for the user. Use when leaving any PR comment, review comment, or reply on GitHub.
---

# Leaving PR comments

Start every comment that you write and post for the user with this GitHub note callout:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

Actual comment starts here.
```

## The attribution note

- Use the verified public name of the model that wrote the comment, and the user's name or GitHub
  login.
- If the harness does not expose a model name, use the harness name. Do not guess.
- Keep the attribution inside the note and the actual reply outside it.
- Start the context line with the robot emoji.
- Do not add a horizontal rule, Setext underline, heading, signature footer, or a second
  attribution.

## Where it applies

Use this format for top-level PR comments, inline review comments, replies to bots or reviewers, and
the written explanation you give before you resolve or dismiss feedback.

Do not add it to PR descriptions, commit messages, or text that the user explicitly asked you to
post verbatim without attribution.

## The comment itself

Write the comment in a direct style:

- Lead with the conclusion.
- Cite the relevant code, behavior, check, or reproduction.
- Keep it short. Leave out filler, canned thanks, and status narration.
- Separate verified facts from judgment.

## Post it

1. Before you post, check the entire comment for secrets and private details. Include quoted text
   and attachments in the check.
2. Preview the final Markdown, so quoting and blank lines render as shown.
3. After you post, verify that GitHub returned the comment or review URL.
4. Resolve a review thread only after its response posted successfully.
