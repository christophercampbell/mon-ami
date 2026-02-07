# mon

Pragmatic engineering principles for Claude Code.

## Installation

```shell
/plugin marketplace add christophercampbell/mon-ami
```

```shell
/plugin install mon@mon-ami
```

## Skill

**`mon:development-principles`** - Invoke when designing, implementing, or reviewing code.

Covers:
- YAGNI, Composability, SOLID, DRY, KISS
- Separation of Concerns, Fail Fast, Error Handling
- Testing Philosophy, Performance, Security
- Code Review, Refactoring, Problem-Solving
- Communication Style, PR Authoring

## Commands

**`/mon:review`** - Reviews recent code changes against the principles.

Evaluates:
1. YAGNI - Speculative code or unnecessary abstraction?
2. SOLID - Clear responsibilities? Focused interfaces?
3. KISS - Is the solution as simple as it could be?
4. Error Handling - Explicit errors? Fail fast?
5. Security - Input validation? Sensitive data exposure?
6. Testing - Testing behavior, not implementation?

Reports findings with file paths and line numbers. Distinguishes "must fix" from "nice to have".

**`/mon:improve`** - Systematic code quality, performance, and maintainability improvements.

**`/mon:research`** - Deep web research with adaptive planning and evidence-based synthesis.

**`/mon:business-panel`** - Multi-expert business analysis using frameworks from Porter, Christensen, Drucker, and others.
