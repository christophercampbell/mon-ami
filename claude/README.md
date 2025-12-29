# claude

Utility commands for Claude Code.

## Installation

```bash
/plugin marketplace add christophercampbell/prompt-plugins
/plugin install claude@prompt-plugins
```

## Commands

**`/claude:skills`** - Lists all available skills in a table format.

**`/claude:optimize`** - Audits and cleans up plugin installation.

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
