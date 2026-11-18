---
name: find-skills
description: Find and install agent skills from the open skills ecosystem. Use when the user asks "how do I do X", "find a skill for X", or "is there a skill that can...", or wants to extend what the agent can do.
---

# Find skills

Find an existing skill that fits the user's need, check its quality, and offer to install it.

The Skills CLI (`npx skills`) is the package manager for the open agent skills ecosystem. Browse the
skills at https://skills.sh/.

| Command | Use |
| --- | --- |
| `npx skills find [query] [--owner <owner>]` | Search by keyword, optionally within one GitHub owner |
| `npx skills add <package>` | Install a skill from GitHub or another source |
| `npx skills update` | Update all installed skills |

## Steps

1. **Understand the need.** Identify the domain (for example React, testing, design, deployment) and
   the specific task (for example writing tests, creating animations, reviewing PRs). Decide whether
   the task is common enough that a skill probably exists.

2. **Check the leaderboard first.** The [skills.sh leaderboard](https://skills.sh/) ranks skills by
   total installs. For web development, the top sources include `vercel-labs/agent-skills` (React,
   Next.js, web design) and `anthropics/skills` (frontend design, document processing).

3. **Search.** If the leaderboard does not cover the need, run the find command:

   ```bash
   npx skills find react performance
   ```

   Use specific keywords: "react testing" is better than "testing". Try other terms: if "deploy"
   finds nothing, try "deployment" or "ci-cd".

4. **Verify quality.** Do not recommend a skill from search results alone. Check all of these:

   - **Install count.** Prefer skills with 1K+ installs. Be careful with anything under 100.
   - **Source reputation.** Official sources (`vercel-labs`, `anthropics`, `microsoft`) are more
     trustworthy than unknown authors.
   - **GitHub stars.** Check the source repository. Be skeptical of a skill from a repo with fewer
     than 100 stars.

5. **Present the options.** For each skill, give its name and what it does, the install count and
   source, the install command, and its skills.sh link. Example:

   ```
   The "react-best-practices" skill gives React and Next.js performance guidelines
   from Vercel Engineering (185K installs).

   Install: npx skills add vercel-labs/agent-skills@react-best-practices
   More: https://skills.sh/vercel-labs/agent-skills/react-best-practices
   ```

6. **Offer to install.** If the user wants the skill, install it for them. `-g` installs it at user
   level, and `-y` skips the confirmation prompts:

   ```bash
   npx skills add <owner/repo@skill> -g -y
   ```

## Search terms by category

| Category | Example queries |
| --- | --- |
| Web development | react, nextjs, typescript, css, tailwind |
| Testing | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| Documentation | docs, readme, changelog, api-docs |
| Code quality | review, lint, refactor, best-practices |
| Design | ui, ux, design-system, accessibility |
| Productivity | workflow, automation, git |

## When no skill fits

Tell the user that you found no existing skill. Offer to do the task directly. If the user does the
task often, suggest that they create their own skill with `npx skills init <name>`.
