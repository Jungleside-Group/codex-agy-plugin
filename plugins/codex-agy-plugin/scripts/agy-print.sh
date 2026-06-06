#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--timeout DURATION|--print-timeout DURATION] [--add-dir PATH]... PROMPT\n' "$0" >&2
}

timeout="10m"
args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout|--print-timeout)
      if [[ $# -lt 2 ]]; then
        usage
        exit 2
      fi
      timeout="$2"
      shift 2
      ;;
    --add-dir)
      if [[ $# -lt 2 ]]; then
        usage
        exit 2
      fi
      args+=(--add-dir "$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

if ! command -v agy >/dev/null 2>&1; then
  printf 'agy was not found on PATH. Install and authenticate Antigravity CLI first.\n' >&2
  exit 127
fi

prompt="$*"
exec agy "${args[@]}" --print --print-timeout "$timeout" "$prompt"
