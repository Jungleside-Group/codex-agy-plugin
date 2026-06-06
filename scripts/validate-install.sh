#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d "${TMPDIR:-/tmp}/codex-agy-install.XXXXXX")"
plugin_cache="$tmp_home/plugins/cache/codex-agy-plugin/codex-agy-plugin"

trap 'rm -rf "$tmp_home"' EXIT

if ! command -v codex >/dev/null 2>&1; then
  printf 'codex CLI was not found on PATH.\n' >&2
  exit 127
fi

CODEX_HOME="$tmp_home" codex plugin marketplace add "$root" >/dev/null
CODEX_HOME="$tmp_home" codex plugin add codex-agy-plugin@codex-agy-plugin >/dev/null

installed_root="$(find "$plugin_cache" -maxdepth 1 -mindepth 1 -type d | sort | tail -n 1)"

if [[ -z "$installed_root" ]]; then
  printf 'Plugin cache was not created under %s.\n' "$plugin_cache" >&2
  exit 1
fi

test -f "$installed_root/.codex-plugin/plugin.json"
test -f "$installed_root/LICENSE"
test -f "$installed_root/skills/agy/SKILL.md"
test -x "$installed_root/scripts/agy-print.sh"

CODEX_HOME="$tmp_home" codex plugin list | grep -q 'codex-agy-plugin@codex-agy-plugin'

printf 'Install validation passed: %s\n' "$installed_root"
