#!/usr/bin/env bash
# Installs the personal Claude Code skills/agents into ~/.claude on this machine.
# Run:  bash install.sh
set -euo pipefail

src="$(cd "$(dirname "$0")/claude" && pwd)"
dest="$HOME/.claude"

mkdir -p "$dest/skills" "$dest/agents"
cp -R "$src/skills/." "$dest/skills/"
cp -R "$src/agents/." "$dest/agents/"

echo "Installed to $dest. Restart Claude Code, then type '/' to confirm migrate-feature and fdp-table-and-constants are listed."
