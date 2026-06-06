#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
marketplace="$root/.agents/plugins/marketplace.json"
plugin_root="$root/plugins/codex-agy-plugin"
plugin_manifest="$plugin_root/.codex-plugin/plugin.json"
skill="$plugin_root/skills/agy/SKILL.md"
wrapper="$plugin_root/scripts/agy-print.sh"
mock_bin="$(mktemp -d "${TMPDIR:-/tmp}/codex-agy-validate.XXXXXX")"

trap 'rm -rf "$mock_bin"' EXIT

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

python3 - "$marketplace" "$plugin_manifest" "$skill" "$root/README.md" <<'PY'
import json
import sys

marketplace_path, plugin_path, skill_path, readme_path = sys.argv[1:5]

with open(marketplace_path, encoding="utf-8") as handle:
    marketplace = json.load(handle)
with open(plugin_path, encoding="utf-8") as handle:
    plugin = json.load(handle)
with open(skill_path, encoding="utf-8") as handle:
    skill = handle.read()
with open(readme_path, encoding="utf-8") as handle:
    readme = handle.read()

assert marketplace["name"] == "codex-agy-plugin"
assert marketplace["plugins"][0]["name"] == "codex-agy-plugin"
assert marketplace["plugins"][0]["source"]["path"] == "./plugins/codex-agy-plugin"
assert plugin["name"] == "codex-agy-plugin"
assert plugin["skills"] == "./skills/"
assert plugin["interface"]["displayName"] == "Codex Agy"
assert skill.startswith("---\n")
frontmatter, _, _ = skill[4:].partition("\n---")
assert "name: agy" in frontmatter
assert "description:" in frontmatter
assert "../../scripts/agy-print.sh" in skill
assert "plugins/codex-agy-plugin/scripts/agy-print.sh" in readme
assert '-- "-starting prompt text"' in skill
assert '-- "-starting prompt text"' in readme
PY

cat > "$mock_bin/agy" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@"
SH
chmod +x "$mock_bin/agy"

run_wrapper() {
  PATH="$mock_bin:$PATH" "$wrapper" "$@"
}

assert_output() {
  local label="$1"
  local expected="$2"
  shift 2

  local actual
  actual="$(run_wrapper "$@")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Wrapper test failed: %s\nExpected:\n%s\nActual:\n%s\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_output \
  "prompt without add-dir" \
  $'--print\n--print-timeout\n10m\n--\nSay exactly: hello' \
  "Say exactly: hello"

assert_output \
  "prompt with add-dir" \
  $'--add-dir\n/tmp/example-repo\n--print\n--print-timeout\n10m\n--\nReview' \
  --add-dir /tmp/example-repo "Review"

assert_output \
  "print-timeout alias" \
  $'--print\n--print-timeout\n15m\n--\nReview' \
  --print-timeout 15m "Review"

assert_output \
  "prompt starting with dash" \
  $'--print\n--print-timeout\n10m\n--\n-starting prompt' \
  -- "-starting prompt"

if run_wrapper --timeout >/dev/null 2>&1; then
  printf 'Wrapper test failed: missing timeout value should fail.\n' >&2
  exit 1
fi

printf 'Validation passed.\n'
