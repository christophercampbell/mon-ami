# ami

Utility commands and skills for Claude Code.

## Installation

```shell
/plugin marketplace add christophercampbell/mon-ami
```

```shell
/plugin install ami@mon-ami
```

## Skills

**`ami:confidence-check`** - Pre-implementation confidence assessment (≥90% required).

Use before starting any implementation to verify:
- No duplicate implementations exist
- Architecture compliance verified
- Official documentation reviewed
- Working OSS implementations found
- Root cause properly identified

**`ami:restore-mcp`** - Restore MCP server connections when Claude loses them between projects.

Re-registers: context7, sequential-thinking, circle, atlassian, tavily. Requires `TAVILY_API_KEY` env var.

## Commands

**`/ami:skills`** - Lists all available skills in a table format.

**`/ami:prune`** - Audits and cleans up plugin installation.

Checks:
- Orphaned cache (in cache but not enabled)
- Old versions (multiple versions, only latest needed)
- Manifest drift (entries pointing to deleted paths)
- Empty plugins (cache exists but contains 0 files)

Locations audited:
| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | Active plugins |
| `~/.claude/plugins/installed_plugins_v2.json` | Install metadata |
| `~/.claude/plugins/cache/` | Plugin files |
