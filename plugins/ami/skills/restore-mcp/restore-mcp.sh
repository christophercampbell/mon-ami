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

add_mcp() {
  local name="$1"
  shift
  if claude mcp add "$name" "$@" 2>/dev/null; then
    echo "  Added $name"
  else
    echo "  $name already configured, skipping"
  fi
}

if [ -n "${CONTEXT7_API_KEY:-}" ]; then
  add_mcp context7 -e CONTEXT7_API_KEY="$CONTEXT7_API_KEY" -- npx -y @upstash/context7-mcp
else
  add_mcp context7 -- npx -y @upstash/context7-mcp
fi
add_mcp sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
add_mcp circle --transport http https://codegenerator-staging.circle.com/api/mcp
add_mcp atlassian --transport http https://mcp.atlassian.com/v1/mcp

if [ -n "${TAVILY_API_KEY:-}" ]; then
  add_mcp tavily --transport http --scope user https://mcp.tavily.com/mcp --header "Authorization: Bearer $TAVILY_API_KEY"
else
  echo "Skipping tavily (TAVILY_API_KEY not set)"
fi

echo "Done! Verifying..."
claude mcp list
