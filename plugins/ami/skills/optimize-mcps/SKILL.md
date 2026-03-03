---
name: optimize-mcps
description: Deduplicate per-project MCP servers that shadow global definitions
allowed-tools: Read, Edit, Write, Bash(node -e:*)
---

<!-- Why a skill? The allowed-tools grants pre-approved access to ~/.claude.json so deduplication can execute without prompting. -->

Audit `~/.claude.json` for per-project MCP server entries that duplicate the global `mcpServers` block, and remove them. The global block is the single source of truth — per-project copies are redundant bloat created by `/mcp add` and plugin setup commands that lack a `--global` flag.

## Locations

| File | Purpose |
|------|---------|
| `~/.claude.json` | Top-level `mcpServers` (global) and `projects[*].mcpServers` (per-project) |

## Execution

Two-phase model: audit first, execute only after confirmation.

### Phase 1: Audit (default)

1. Read `~/.claude.json`
2. Parse the top-level `mcpServers` object — these are the global servers
3. For each project in `projects`, compare `projects[path].mcpServers` against the global set
4. Classify each per-project server entry:
   - **Redundant** — identical to a global entry (same name, type, url/command/args)
   - **Override** — same name as a global entry but different config (e.g. extra env vars)
   - **Project-only** — not present in global `mcpServers` at all
5. Present the **Proposed Actions** report
6. Ask the user to confirm before proceeding

### Phase 2: Execute (on confirmation)

After the user reviews the report and confirms:

1. For each project, remove all **Redundant** entries from `projects[path].mcpServers`
2. Leave **Override** and **Project-only** entries untouched
3. Write the updated JSON back to `~/.claude.json` (2-space indent)
4. Present the **Completed Actions** report

Use `node -e` to read, transform, and write the JSON to avoid malformed output.

## Comparison Logic

Two MCP server entries are considered identical when:
- Same server name (key)
- Same `type`
- For `stdio` type: same `command` and `args` (ignore `env` if both empty or absent)
- For `http` type: same `url`

An entry with extra `env` vars, `headers`, or other fields not present in the global definition is an **Override**, not redundant.

## Output Format

### During Audit (Phase 1)

Summary line first:

> Found N redundant MCP entries across M projects (K projects clean).

Then the detail table — only list projects with findings:

| Project | Server | Status | Detail |
|---------|--------|--------|--------|
| ~/code/foo | context7 | Redundant | identical to global |
| ~/code/foo | circle | Redundant | identical to global |
| ~/code/bar | context7 | Override | has CONTEXT7_API_KEY env |
| ~/code/baz | custom-server | Project-only | not in global |

Follow with: "No changes made. Confirm to proceed, or cancel."

### After Execution (Phase 2)

| Project | Server | Result |
|---------|--------|--------|
| ~/code/foo | context7 | removed |
| ~/code/foo | circle | removed |

Summary: "Removed N redundant entries across M projects. Overrides and project-only servers preserved."

## Verification

After cleanup, verify:
- `~/.claude.json` is valid JSON
- Global `mcpServers` block is unchanged
- No **Override** or **Project-only** entries were removed
- Report total projects, clean projects, and remaining per-project entries

Changes take effect in new Claude Code sessions.
