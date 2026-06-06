---
name: agy
description: Use when the user asks Codex to call Antigravity CLI, agy, Google Antigravity, run an Antigravity review, ask Antigravity for a second opinion, or delegate planning, analysis, or code review from Codex to Antigravity.
---

# Antigravity CLI from Codex

Use the local Antigravity CLI (`agy`) as a second agent from inside Codex.

## Before Invoking

1. Inspect enough local context to form a bounded prompt.
2. Check that `agy` is installed with `command -v agy` and `agy --version`.
3. Do not install, update, or authenticate `agy` unless the user explicitly asks.
4. Do not pass secrets, credentials, private keys, tokens, or unrelated personal data into prompts.
5. Prefer small, explicit prompts that name the repository, relevant files, current goal, and exact output requested.

## Invocation Modes

Use non-interactive print mode for most Codex workflows:

```bash
agy --print "Review this plan for risks and missing tests: ..."
```

This plugin also includes a small wrapper at `../../scripts/agy-print.sh` relative to this skill directory. Prefer the wrapper when you want a default 10 minute timeout and simple `--add-dir` handling:

```bash
../../scripts/agy-print.sh --add-dir /absolute/path/to/repo "Review the current diff."
```

Use a bounded timeout when the request may take longer:

```bash
agy --print --print-timeout 10m "Review the current diff for bugs and regressions."
```

Use `--add-dir` when Antigravity needs additional workspace roots:

```bash
agy --add-dir /absolute/path/to/repo --print "Analyze this repository slice: ..."
```

Use interactive mode only when the user explicitly wants to continue in Antigravity:

```bash
agy --prompt-interactive "Start from this context: ..."
```

## Sandbox Handling

`agy` may create logs, start a local language-server process, or open network connections. If it fails with filesystem, logging, or localhost bind errors inside Codex sandboxing, explain the failure briefly and rerun only with the user's approval through Codex's normal escalation flow.

Do not use `--dangerously-skip-permissions` unless the user explicitly requests it for a trusted local workspace.

## Response Contract

After `agy` returns:

1. Summarize Antigravity's useful findings.
2. Separate confirmed local facts from Antigravity suggestions.
3. Verify any proposed code change against local files before applying it.
4. If Antigravity's answer is unclear or too broad, narrow the prompt and run a follow-up rather than treating it as authoritative.
