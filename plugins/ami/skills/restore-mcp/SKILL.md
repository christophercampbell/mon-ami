---
name: restore-mcp
description: Restore MCP server connections when Claude loses them between projects
allowed-tools: Bash(claude mcp:*), Bash(echo:*), Read
---

Restore MCP server connections. Claude sometimes loses MCP configurations between projects — run this to re-register them.

## When to Use

- MCP tools are missing or failing with connection errors
- Starting a new project and MCP servers aren't available
- After Claude Code updates that reset MCP configuration

## Execution

Run the restore script:

```bash
bash plugins/ami/skills/restore-mcp/restore-mcp.sh
```

If the script is not at that path (e.g., running from a different project), find it:

```bash
bash ~/.claude/plugins/cache/mon-ami/ami/*/skills/restore-mcp/restore-mcp.sh
```

After running, verify the servers are registered:

```bash
claude mcp list
```

## Requirements

- `TAVILY_API_KEY` environment variable must be set for the Tavily MCP server
- `CONTEXT7_API_KEY` environment variable must be set for authenticated Context7 access (works without it, but rate-limited)
- `npx` must be available (Node.js installed)
