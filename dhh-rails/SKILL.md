---
name: dhh-rails
description: Apply DHH and 37signals conventions to Ruby and Rails backend code, including models, controllers, routes, jobs, and persistence. Use when implementing or reviewing Rails backend code in that style, or when the user asks for DHH or 37signals style. Not for frontend-only work.
---

# DHH Rails

Apply 37signals and DHH conventions to Ruby and Rails backend code, within the requested change. The
conventions come from an analysis of production 37signals code (Fizzy and Campfire) and DHH's code
reviews.

"The best code is the code you don't write. The second best is the code that's obviously correct."

## Scope

These rules take precedence over everything else in this skill and its references.

- **Apply the backend guidance.** Use the Ruby naming, domain modeling, REST routing, small
  controller, job, persistence, and simplicity guidance within the requested change.
- **Keep the project's frontend.** In Rails + React + Inertia applications, follow the project's
  existing Inertia patterns for rendering, props, forms, redirects, navigation, and TypeScript. Do
  not introduce Turbo or Stimulus, and do not replace React, Inertia, Tailwind, or shadcn to satisfy
  this style. Read the frontend reference only for a Hotwire task that the user explicitly asked
  for.
- **Keep what the project already uses.** Keep its authorization and authentication approaches, test
  frameworks, fixtures or factories, job backends, caches, and dependencies. The lists below of what
  37signals use and avoid are examples, not migration requirements.
- **Repository conventions and explicit user instructions win** over the stylistic preferences here.
- **Do not add tests** unless the user or the applicable project instructions authorize them. Use
  the existing checks and workflow verification.
- **Model state as records when it earns it.** Do that when the state's lifecycle or metadata
  warrants it. Simple boolean state does not automatically need a new table.
- **Combine database constraints with useful model validations.** Do not remove validations.
- **Do not interview the user.** Infer the relevant reference from the task and read only what you
  need. Continue without questions when the request is clear.

## Core philosophy

Vanilla Rails is plenty:

- Rich domain models over service objects
- CRUD controllers over custom actions
- Concerns for horizontal code sharing
- Records as state instead of boolean columns
- Database-backed everything (no Redis)
- Build solutions before reaching for gems

What 37signals deliberately avoid:

- devise (a custom auth of about 150 lines instead)
- pundit and cancancan (simple role checks in models)
- sidekiq (Solid Queue uses the database)
- redis (the database for everything)
- view_component (partials work fine)
- GraphQL (REST with Turbo is sufficient)
- factory_bot (fixtures are simpler)
- rspec (Minitest ships with Rails)
- Tailwind (native CSS with layers)

How they develop:

- Ship, validate, refine: put prototype-quality code in production to learn
- Fix root causes, not symptoms
- Write-time operations over read-time computations
- Database constraints over ActiveRecord validations

## References

Read the reference that matches the task. For a code review, read all the references that the code
touches.

| Task | Reference | Topics |
| --- | --- | --- |
| Controllers | [controllers.md](references/controllers.md) | REST mapping, concerns, Turbo responses, API patterns, HTTP caching |
| Models | [models.md](references/models.md) | Concerns, state records, callbacks, scopes, POROs, authorization, broadcasting |
| Architecture | [architecture.md](references/architecture.md) | Routing, authentication, jobs, Current attributes, caching, database patterns |
| Gems and dependencies | [gems.md](references/gems.md) | What they use and avoid, decision framework, Gemfile examples |
| Testing | [testing.md](references/testing.md) | Minitest, fixtures, unit, integration, and system tests |
| Hotwire frontend (only on explicit request) | [frontend.md](references/frontend.md) | Turbo Streams, Stimulus controllers, CSS layers, OKLCH colors, partials |

## Naming

- **Verbs:** `card.close`, `card.gild`, `board.publish` (not `set_style` methods)
- **Predicates:** `card.closed?`, `card.golden?` (derived from the presence of a related record)
- **Concerns:** adjectives that describe a capability (`Closeable`, `Publishable`, `Watchable`)
- **Controllers:** nouns that match resources (`Cards::ClosuresController`)
- **Scopes:**
  - `chronologically`, `reverse_chronologically`, `alphabetically`, `latest`
  - `preloaded` (the standard name for eager loading)
  - `indexed_by`, `sorted_by` (parameterized)
  - `active`, `unassigned` (business terms, not SQL terms)

## REST mapping

Create new resources instead of custom actions:

```
POST /cards/:id/close    → POST /cards/:id/closure
DELETE /cards/:id/close  → DELETE /cards/:id/closure
POST /cards/:id/archive  → POST /cards/:id/archival
```

## Ruby syntax

```ruby
# Symbol arrays with spaces inside brackets
before_action :set_message, only: %i[ show edit update destroy ]

# Private method indentation
  private
    def set_message
      @message = Message.find(params[:id])
    end

# Expression-less case for conditionals
case
when params[:before].present?
  messages.page_before(params[:before])
else
  messages.last_page
end

# Bang methods for fail-fast
@message = Message.create!(params)

# Ternaries for simple conditionals
@room.direct? ? @room.users : @message.mentionees
```

## Key patterns

State as records:

```ruby
Card.joins(:closure)         # closed cards
Card.where.missing(:closure) # open cards
```

Current attributes:

```ruby
belongs_to :creator, default: -> { Current.user }
```

Authorization on models:

```ruby
class User < ApplicationRecord
  def can_administer?(message)
    message.creator == self || admin?
  end
end
```

## Done when

The code follows the style when:

- Controllers map to CRUD verbs on resources.
- Models use concerns for horizontal behavior.
- State with a lifecycle is tracked through records, not booleans.
- There are no unnecessary service objects or abstractions.
- Jobs are shallow wrappers that call model methods.
- The project's frontend, authorization, test framework, and dependencies are unchanged, unless the
  user asked to change them.

## Credits

Based on [The Unofficial 37signals/DHH Rails Style
Guide](https://github.com/marckohlbrugge/unofficial-37signals-coding-style-guide) by [Marc
Köhlbrugge](https://x.com/marckohlbrugge), which analyzed 265 pull requests from the Fizzy codebase.

- The guide is LLM-generated and may contain inaccuracies.
- Code examples from Fizzy are licensed under the O'Saasy License.
- It is not affiliated with or endorsed by 37signals.
