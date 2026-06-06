#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
marketplace="$root/.agents/plugins/marketplace.json"
plugin_root="$root/plugins/codex-agy-plugin"
plugin_manifest="$plugin_root/.codex-plugin/plugin.json"
skill="$plugin_root/skills/agy/SKILL.md"
wrapper="$plugin_root/scripts/agy-print.sh"

require_file() {
  if [[ ! -f "$1" ]]; then
    printf 'Missing required file: %s\n' "$1" >&2
    exit 1
  fi
}

require_file "$marketplace"
require_file "$plugin_manifest"
require_file "$skill"
require_file "$wrapper"

python3 -m json.tool "$marketplace" >/dev/null
python3 -m json.tool "$plugin_manifest" >/dev/null
bash -n "$wrapper"

if [[ ! -x "$wrapper" ]]; then
  printf 'Wrapper is not executable: %s\n' "$wrapper" >&2
  exit 1
fi

python3 - "$marketplace" "$plugin_manifest" <<'PY'
import json
import sys

marketplace_path, plugin_path = sys.argv[1:3]

with open(marketplace_path, encoding="utf-8") as handle:
    marketplace = json.load(handle)
with open(plugin_path, encoding="utf-8") as handle:
    plugin = json.load(handle)

assert marketplace["name"] == "codex-agy-plugin"
assert marketplace["plugins"][0]["name"] == "codex-agy-plugin"
assert marketplace["plugins"][0]["source"]["path"] == "./plugins/codex-agy-plugin"
assert plugin["name"] == "codex-agy-plugin"
assert plugin["skills"] == "./skills/"
assert plugin["interface"]["displayName"] == "Codex Agy"
PY

printf 'Validation passed.\n'

