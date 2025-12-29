# Claude Plugins

A collection of plugins for Claude Code.

## Plugins

### dev

Pragmatic engineering principles: YAGNI, SOLID, KISS, DRY, fail fast, and more.

**Skill:** `dev:development-principles`
- Invoke when designing, implementing, or reviewing code
- Covers: YAGNI, Composability, SOLID, DRY, KISS, Separation of Concerns, Fail Fast, Error Handling, Testing, Performance, Security, Code Review, Refactoring, Problem-Solving, Communication Style, PR Authoring

**Command:** `/dev:review`
- Reviews recent code changes against the principles
- Reports findings with file paths and line numbers

### claude

Utility commands for Claude Code itself.

**Command:** `/claude:skills`
- Lists all available skills in a table format

**Command:** `/claude:optimize`
- Audits and cleans up plugin installation
- Identifies orphaned caches, old versions, manifest drift

## Installation

Add the marketplace, then install plugins:

```bash
/plugin marketplace add christophercampbell/claude-plugins
/plugin install dev@claude-plugins
/plugin install claude@claude-plugins
```

Or use `/plugin` to browse and install interactively.

## License

MIT
