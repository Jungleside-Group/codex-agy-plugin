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
require_contains "$readme" 'codex plugin add codex-agy-plugin@codex-agy-plugin' 'README includes reinstall guidance'
require_contains "$readme" 'tested with `agy 1\.0\.6` and compatible print-mode arguments' 'README states tested agy compatibility'
require_contains "$readme" 'scripts/validate\.sh' 'README includes core validation command'
require_contains "$readme" 'scripts/validate-install\.sh' 'README includes install smoke command'
require_contains "$readme" 'plugins/codex-agy-plugin/scripts/agy-print\.sh' 'README includes repo checkout wrapper path'
require_contains "$readme" 'Place wrapper options before `PROMPT`' 'README documents wrapper option order'
require_contains "$readme" 'Repository root `scripts/validate\*\.sh` files are development validators' 'README explains root validation scripts'
require_contains "$readme" 'plugins/codex-agy-plugin/scripts/agy-print\.sh` is the runtime wrapper' 'README explains plugin runtime wrapper'
require_contains "$readme" '^[[:space:]]*LICENSE$' 'README includes distributed plugin license'
require_contains "$readme" '^[[:space:]]*plugins/codex-agy-plugin/scripts/agy-print\.sh -- "-starting prompt text"' 'README documents dash-prefixed prompts'

require_contains "$skill" 'Resolve an absolute wrapper path from the installed skill file location' 'SKILL explains installed absolute wrapper resolution'
require_contains "$skill" 'Place wrapper options before the prompt' 'SKILL documents wrapper option order'
require_contains "$skill" 'skill_path="/absolute/path/to/codex-agy-plugin/skills/agy/SKILL\.md"' 'SKILL includes installed skill path example'
require_contains "$skill" 'dirname "\$skill_path"' 'SKILL derives wrapper path from installed skill path'
require_contains "$skill" 'target repository|target repo' 'SKILL warns about target repository cwd'
require_contains "$skill" '^[[:space:]]*"\$wrapper" -- "-starting prompt text"' 'SKILL documents dash-prefixed prompts'
require_contains "$skill" 'agy --print ".*" --print-timeout' 'SKILL documents agy 1.0.6 prompt-first timeout order'
require_contains "$skill" 'tested with `agy 1\.0\.6`; use a version with compatible' 'SKILL states tested agy compatibility'
require_contains "$skill" 'Do not modify files|Return findings only' 'SKILL preserves read-only review guidance'

printf 'Documentation validation passed.\n'
