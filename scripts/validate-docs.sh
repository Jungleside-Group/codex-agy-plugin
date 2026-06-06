#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme="$root/README.md"
skill="$root/plugins/codex-agy-plugin/skills/agy/SKILL.md"

require_file() {
  if [[ ! -f "$1" ]]; then
    printf 'Missing required file: %s\n' "$1" >&2
    exit 1
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if ! grep -Eq -- "$pattern" "$file"; then
    printf 'Documentation check failed: %s\nFile: %s\nPattern: %s\n' "$label" "$file" "$pattern" >&2
    exit 1
  fi
}

require_file "$readme"
require_file "$skill"

require_contains "$readme" 'codex plugin marketplace add' 'README includes install guidance'
require_contains "$readme" 'scripts/validate\.sh' 'README includes core validation command'
require_contains "$readme" 'scripts/validate-install\.sh' 'README includes install smoke command'
require_contains "$readme" 'plugins/codex-agy-plugin/scripts/agy-print\.sh' 'README includes repo checkout wrapper path'
require_contains "$readme" '^[[:space:]]*plugins/codex-agy-plugin/scripts/agy-print\.sh -- "-starting prompt text"' 'README documents dash-prefixed prompts'

require_contains "$skill" '^[[:space:]]*\.\./\.\./scripts/agy-print\.sh' 'SKILL includes installed skill-relative wrapper path'
require_contains "$skill" 'target repository|target repo' 'SKILL warns about target repository cwd'
require_contains "$skill" '^[[:space:]]*plugins/codex-agy-plugin/scripts/agy-print\.sh -- "-starting prompt text"' 'SKILL documents dash-prefixed prompts'
require_contains "$skill" 'Do not modify files|Return findings only' 'SKILL preserves read-only review guidance'

printf 'Documentation validation passed.\n'
