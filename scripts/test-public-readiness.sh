#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_check() {
  local label="$1"
  shift

  printf '==> %s\n' "$label"
  "$@"
}

run_check "Validate plugin source" "$root/scripts/validate.sh"
run_check "Validate documentation" "$root/scripts/validate-docs.sh"
run_check "Validate local plugin install" "$root/scripts/validate-install.sh"

printf 'Public readiness checks passed.\n'
