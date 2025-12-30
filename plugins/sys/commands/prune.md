---
description: Audit and clean up Claude Code plugin installation
---
Audit and clean up Claude Code plugin installation.

## Locations

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | `enabledPlugins` - what's active |
| `~/.claude/plugins/installed_plugins_v2.json` | Manifest - install metadata |
| `~/.claude/plugins/cache/<registry>/<plugin>/<version>/` | Actual plugin files |

## Audit Steps

1. **List enabled plugins** from `settings.json`
2. **List cached plugins** in `~/.claude/plugins/cache/`
3. **Check manifest** for duplicate entries or stale references
4. **Identify issues:**
   - Orphaned cache: in cache but not enabled
   - Old versions: multiple versions, only latest needed
   - Manifest drift: entries pointing to deleted paths
   - Empty plugins: cache directory exists but contains 0 files

## Cleanup Actions

```bash
# Remove orphaned plugin cache
rm -rf ~/.claude/plugins/cache/<registry>/<plugin>

# Remove old versions (keep latest)
rm -rf ~/.claude/plugins/cache/<registry>/<plugin>/<old-version>

# Remove empty registry directories
rmdir ~/.claude/plugins/cache/<registry> 2>/dev/null
```

For manifest fixes, edit `installed_plugins_v2.json`:
- Remove entries for disabled plugins
- Remove duplicate version entries (keep latest)
- Ensure paths match existing cache directories

## Common Issues

| Issue | Fix |
|-------|-----|
| Plugin disabled but still in cache | Delete cache directory |
| Multiple versions in cache | Keep latest, delete others |
| Duplicate manifest entries | Keep one entry per plugin |
| Manifest points to missing path | Remove stale entry |
| Empty registry directory | Delete it |
| Empty plugin (0 files in cache) | Disable, remove from manifest, delete cache |

## Detecting Empty Plugins

```bash
# List plugins with file counts
find ~/.claude/plugins/cache -mindepth 3 -maxdepth 3 -type d \
  -exec sh -c 'echo "$1: $(find "$1" -type f | wc -l) files"' _ {} \;
```

Empty plugins are stub definitions with no actual content - disable and remove them.

## Verification

After cleanup, verify:
```bash
# Check cache structure
ls ~/.claude/plugins/cache/*/

# Verify manifest valid JSON
cat ~/.claude/plugins/installed_plugins_v2.json | jq .

# Count: enabled == manifest entries == cache directories
```

Changes take effect in new Claude Code sessions.
