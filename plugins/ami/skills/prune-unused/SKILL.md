---
name: prune-unused
description: Audit and clean up Claude Code plugin installation
allowed-tools: Read, Edit, Write, Bash(rm -rf:*), Bash(rmdir:*), Bash(find:*), Glob
---

<!-- Why a skill? The allowed-tools grants pre-approved access to ~/.claude files, so cleanup can execute without prompting for every read/write/delete. -->

Audit Claude Code plugin installation and report proposed cleanup actions. Destructive actions require explicit user confirmation.

## Locations

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | `enabledPlugins` - what's active |
| `~/.claude/plugins/installed_plugins_v2.json` | Manifest - install metadata |
| `~/.claude/plugins/cache/<registry>/<plugin>/<version>/` | Actual plugin files |

## Execution

Two-phase model: audit first, execute only after confirmation.

### Phase 1: Audit (default)

1. Read `settings.json` to get enabled plugins
2. Scan `~/.claude/plugins/cache/` for all cached plugins
3. Read manifest `installed_plugins_v2.json`
4. Identify all issues
5. Present the **Proposed Actions** report (see Output Format)
6. Ask the user to confirm before proceeding

### Phase 2: Execute (on confirmation)

After the user reviews the report and confirms, or if invoked with `--execute`:

1. Execute all proposed fixes
2. Present the **Completed Actions** report

## Issues to Fix

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

### During Audit (Phase 1)

Present proposed actions — no changes made yet:

| Proposed Action | Target | Detail |
|-----------------|--------|--------|
| Delete orphaned cache | mon-ami/old-plugin | not in enabledPlugins |
| Remove old version | superpowers/1.0.0 | newer version exists |
| Fix manifest entry | stale-plugin | points to missing path |

Follow the table with: "No changes made. Confirm to proceed, or cancel."

### After Execution (Phase 2)

Report completed actions:

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
