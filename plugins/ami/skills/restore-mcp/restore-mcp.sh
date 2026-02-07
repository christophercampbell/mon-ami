#!/bin/bash
# Restore MCP servers if they get wiped between projects

set -euo pipefail

if [ -z "${TAVILY_API_KEY:-}" ]; then
  echo "Warning: TAVILY_API_KEY is not set. Tavily MCP server will not be configured."
  echo "Set it with: export TAVILY_API_KEY=your-key-here"
fi

if [ -z "${CONTEXT7_API_KEY:-}" ]; then
  echo "Warning: CONTEXT7_API_KEY is not set. Context7 will use unauthenticated/rate-limited access."
  echo "Set it with: export CONTEXT7_API_KEY=your-key-here"
fi

echo "Restoring MCP servers..."

if [ -n "${CONTEXT7_API_KEY:-}" ]; then
  claude mcp add context7 -e CONTEXT7_API_KEY="$CONTEXT7_API_KEY" -- npx -y @upstash/context7-mcp
else
  claude mcp add context7 -- npx -y @upstash/context7-mcp
fi
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
claude mcp add circle --transport http https://codegenerator-staging.circle.com/api/mcp
claude mcp add atlassian --transport http https://mcp.atlassian.com/v1/mcp

if [ -n "${TAVILY_API_KEY:-}" ]; then
  claude mcp add tavily --transport http --scope user https://mcp.tavily.com/mcp --header "Authorization: Bearer $TAVILY_API_KEY"
else
  echo "Skipping tavily (TAVILY_API_KEY not set)"
fi

echo "Done! Verifying..."
claude mcp list
