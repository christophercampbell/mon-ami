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

if [ -z "${SONARQUBE_TOKEN:-}" ]; then
  echo "Warning: SONARQUBE_TOKEN is not set. SonarQube MCP server will not be configured."
  echo "Generate a token at https://sonarqube.circle.com/account/security"
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
  add_mcp context7 --scope user -e CONTEXT7_API_KEY="$CONTEXT7_API_KEY" -- npx -y @upstash/context7-mcp
else
  add_mcp context7 --scope user -- npx -y @upstash/context7-mcp
fi
add_mcp sequential-thinking --scope user -- npx -y @modelcontextprotocol/server-sequential-thinking
add_mcp circle --scope user --transport http https://codegenerator-staging.circle.com/api/mcp
add_mcp glean_default --scope user --transport http https://circle-be.glean.com/mcp/default
add_mcp atlassian --scope user --transport http https://mcp.atlassian.com/v1/mcp

# Circle-recommended MCPs (from crcl-main/ai-coding circle-recommended-mcps plugin)
add_mcp datadog --scope user --transport http https://mcp.datadoghq.com/api/unstable/mcp-server/mcp
add_mcp figma --scope user --transport http https://mcp.figma.com/mcp

if [ -n "${SONARQUBE_TOKEN:-}" ]; then
  add_mcp sonarqube --scope user -- docker run --rm -i -e SONARQUBE_URL=https://sonarqube.circle.com/ -e "SONARQUBE_TOKEN=$SONARQUBE_TOKEN" mcp/sonarqube
else
  echo "Skipping sonarqube (SONARQUBE_TOKEN not set)"
fi

if [ -n "${TAVILY_API_KEY:-}" ]; then
  add_mcp tavily --scope user --transport http https://mcp.tavily.com/mcp --header "Authorization: Bearer $TAVILY_API_KEY"
else
  echo "Skipping tavily (TAVILY_API_KEY not set)"
fi

echo "Done! Verifying..."
claude mcp list
