---
name: ce-dhh-rails-style
description: Apply DHH-inspired Ruby and Rails backend conventions when implementing or reviewing models, controllers, routes, jobs, and persistence. Use for DHH or 37signals style requests. Preserve the existing frontend, authorization, dependencies, and test framework; frontend-only work is outside this skill.
---


## Local scope and precedence

This installation adapts EveryInc/compound-engineering-plugin at commit
`5c0ec9137a7350534e32db91e8bad66f02693716` for Rails backend work.
The following scope rules override conflicting guidance in the upstream body
and all bundled references below.

- Apply the Ruby naming, domain modeling, REST routing, small controller, job,
  persistence, and simplicity guidance within the requested change.
- Preserve the project's frontend. In Rails + React + Inertia applications,
  follow the project's existing Inertia patterns for rendering, props, forms,
  redirects, navigation, and TypeScript. Do not introduce Turbo/Stimulus or replace React,
  Inertia, Tailwind, or shadcn to satisfy this style guide. Read the frontend
  reference only for an explicitly requested Hotwire task.
- Preserve existing authorization and authentication approaches, test frameworks,
  fixtures or factories, job backends, caches, and dependencies. The upstream
  gem avoidance list and preferences for User-model authorization, Minitest,
  and database-backed services are examples, not migration requirements.
- Follow repository conventions and explicit user instructions over stylistic
  preferences here. Do not add tests unless the user or applicable project
  instructions authorize them. Use existing checks and workflow verification.
- Model state as records when its lifecycle or metadata warrants it; simple
  boolean state does not automatically need a new table. Combine database
  constraints with useful model validations rather than removing validation.
- Infer the relevant reference from the task and read only what is needed.
  Continue without the upstream intake questionnaire when the request is clear.


<objective>
Apply 37signals/DHH Rails conventions to Ruby and Rails code. This skill provides comprehensive domain expertise extracted from analyzing production 37signals codebases (Fizzy/Campfire) and DHH's code review patterns.
</objective>

<essential_principles>
## Core Philosophy

"The best code is the code you don't write. The second best is the code that's obviously correct."

**Vanilla Rails is plenty:**
- Rich domain models over service objects
- CRUD controllers over custom actions
- Concerns for horizontal code sharing
- Records as state instead of boolean columns
- Database-backed everything (no Redis)
- Build solutions before reaching for gems

**What they deliberately avoid:**
- devise (custom ~150-line auth instead)
- pundit/cancancan (simple role checks in models)
- sidekiq (Solid Queue uses database)
- redis (database for everything)
- view_component (partials work fine)
- GraphQL (REST with Turbo sufficient)
- factory_bot (fixtures are simpler)
- rspec (Minitest ships with Rails)
- Tailwind (native CSS with layers)

**Development Philosophy:**
- Ship, Validate, Refine - prototype-quality code to production to learn
- Fix root causes, not symptoms
- Write-time operations over read-time computations
- Database constraints over ActiveRecord validations
</essential_principles>

<intake>
What are you working on?

1. **Controllers** - REST mapping, concerns, Turbo responses, API patterns
2. **Models** - Concerns, state records, callbacks, scopes, POROs
3. **Views & Frontend** - Turbo, Stimulus, CSS, partials
4. **Architecture** - Routing, multi-tenancy, authentication, jobs, caching
5. **Testing** - Minitest, fixtures, integration tests
6. **Gems & Dependencies** - What to use vs avoid
7. **Code Review** - Review code against DHH style
8. **General Guidance** - Philosophy and conventions

**Specify a number or describe your task.**
</intake>

<routing>

| Response | Reference to Read |
|----------|-------------------|
| 1, controller | `references/controllers.md` |
| 2, model | `references/models.md` |
| 3, view, frontend, turbo, stimulus, css | `references/frontend.md` |
| 4, architecture, routing, auth, job, cache | `references/architecture.md` |
| 5, test, testing, minitest, fixture | `references/testing.md` |
| 6, gem, dependency, library | `references/gems.md` |
| 7, review | Read all references, then review code |
| 8, general task | Read relevant references based on context |

**After reading relevant references, apply patterns to the user's code.**
</routing>

<quick_reference>
## Naming Conventions

**Verbs:** `card.close`, `card.gild`, `board.publish` (not `set_style` methods)

**Predicates:** `card.closed?`, `card.golden?` (derived from presence of related record)

**Concerns:** Adjectives describing capability (`Closeable`, `Publishable`, `Watchable`)

**Controllers:** Nouns matching resources (`Cards::ClosuresController`)

**Scopes:**
- `chronologically`, `reverse_chronologically`, `alphabetically`, `latest`
- `preloaded` (standard eager loading name)
- `indexed_by`, `sorted_by` (parameterized)
- `active`, `unassigned` (business terms, not SQL-ish)

## REST Mapping

Instead of custom actions, create new resources:

```
POST /cards/:id/close    → POST /cards/:id/closure
DELETE /cards/:id/close  → DELETE /cards/:id/closure
POST /cards/:id/archive  → POST /cards/:id/archival
```

## Ruby Syntax Preferences

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

## Key Patterns

**State as Records:**
```ruby
Card.joins(:closure)         # closed cards
Card.where.missing(:closure) # open cards
```

**Current Attributes:**
```ruby
belongs_to :creator, default: -> { Current.user }
```

**Authorization on Models:**
```ruby
class User < ApplicationRecord
  def can_administer?(message)
    message.creator == self || admin?
  end
end
```
</quick_reference>

<reference_index>
## Domain Knowledge

All detailed patterns in `references/`:

| File | Topics |
|------|--------|
| `references/controllers.md` | REST mapping, concerns, Turbo responses, API patterns, HTTP caching |
| `references/models.md` | Concerns, state records, callbacks, scopes, POROs, authorization, broadcasting |
| `references/frontend.md` | Turbo Streams, Stimulus controllers, CSS layers, OKLCH colors, partials |
| `references/architecture.md` | Routing, authentication, jobs, Current attributes, caching, database patterns |
| `references/testing.md` | Minitest, fixtures, unit/integration/system tests, testing patterns |
| `references/gems.md` | What they use vs avoid, decision framework, Gemfile examples |
</reference_index>

<success_criteria>
Code follows DHH style when:
- Controllers map to CRUD verbs on resources
- Models use concerns for horizontal behavior
- State is tracked via records, not booleans
- No unnecessary service objects or abstractions
- Database-backed solutions preferred over external services
- Tests use Minitest with fixtures
- Turbo/Stimulus for interactivity (no heavy JS frameworks)
- Native CSS with modern features (layers, OKLCH, nesting)
- Authorization logic lives on User model
- Jobs are shallow wrappers calling model methods
</success_criteria>

<credits>
Based on [The Unofficial 37signals/DHH Rails Style Guide](https://github.com/marckohlbrugge/unofficial-37signals-coding-style-guide) by [Marc Köhlbrugge](https://x.com/marckohlbrugge), generated through deep analysis of 265 pull requests from the Fizzy codebase.

**Important Disclaimers:**
- LLM-generated guide - may contain inaccuracies
- Code examples from Fizzy are licensed under the O'Saasy License
- Not affiliated with or endorsed by 37signals
</credits>

