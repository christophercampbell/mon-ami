---
name: prune-unused
description: Audit and clean up Claude Code plugin installation
allowed-tools: Read, Edit, Write, Bash(rm -rf:*), Bash(rmdir:*), Bash(find:*), Glob
---

<!-- Why a skill? The allowed-tools grants pre-approved access to ~/.claude files, so cleanup can execute without prompting for every read/write/delete. -->

Aggressively audit and clean up Claude Code plugin installation. Execute all cleanup actions immediately without asking for confirmation.

## Locations

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | `enabledPlugins` - what's active |
| `~/.claude/plugins/installed_plugins_v2.json` | Manifest - install metadata |
| `~/.claude/plugins/cache/<registry>/<plugin>/<version>/` | Actual plugin files |

## Execution

**DO NOT ASK FOR CONFIRMATION. Execute all cleanup actions immediately.**

1. Read `settings.json` to get enabled plugins
2. Scan `~/.claude/plugins/cache/` for all cached plugins
3. Read manifest `installed_plugins_v2.json`
4. Identify all issues
5. **Execute all fixes immediately**
6. Report what was cleaned up

## Issues to Fix (Automatically)

| Issue | Action |
|-------|--------|
| Orphaned cache (in cache but not enabled) | Delete cache directory |
| Old versions (multiple versions exist) | Delete all but latest |
| Manifest drift (entry points to missing path) | Remove stale entry from manifest |
| Empty plugins (0 files in cache) | Remove from settings, manifest, and cache |
| Empty registry directories | Delete them |
| Duplicate manifest entries | Keep only one entry per plugin |

## Cleanup Commands

```bash
# Remove orphaned plugin cache
rm -rf ~/.claude/plugins/cache/<registry>/<plugin>

# Remove old versions (keep latest)
rm -rf ~/.claude/plugins/cache/<registry>/<plugin>/<old-version>

# Remove empty registry directories
rmdir ~/.claude/plugins/cache/<registry> 2>/dev/null
```

For manifest fixes, edit `installed_plugins_v2.json` directly to remove stale or duplicate entries.

## Output Format

Report cleanup results in this format:

| Action | Target | Result |
|--------|--------|--------|
| Deleted orphaned cache | mon-ami/old-plugin | done |
| Removed old version | superpowers/1.0.0 | done |
| Fixed manifest entry | stale-plugin | removed |

## Verification

After cleanup, verify and report:
- Cache structure is clean
- Manifest is valid JSON
- enabled count == manifest entries == cache directories

Changes take effect in new Claude Code sessions.
