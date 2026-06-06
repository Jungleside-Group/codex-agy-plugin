---
name: agy
description: Use when the user asks Codex to call Antigravity CLI, agy, Google Antigravity, run an Antigravity review, ask Antigravity for a second opinion, or delegate planning, analysis, or code review from Codex to Antigravity.
---

# Antigravity CLI from Codex

Use the local Antigravity CLI (`agy`) as a second agent from inside Codex.

## Before Invoking

1. Inspect enough local context to form a bounded prompt.
2. Check that `agy` is installed with `command -v agy` and `agy --version`. This plugin is tested with `agy 1.0.6`; use a version with compatible `agy --print "prompt" --print-timeout 10m` behavior.
3. Do not install, update, or authenticate `agy` unless the user explicitly asks.
4. Do not pass secrets, credentials, private keys, tokens, or unrelated personal data into prompts.
5. Prefer small, explicit prompts that name the repository, relevant files, current goal, and exact output requested.
6. Default to read-only delegation. Unless the user explicitly asks Antigravity to edit files, the prompt must tell `agy` not to modify files, run write commands, or apply patches.

## Invocation Modes

Use non-interactive print mode for most Codex workflows:

```bash
agy --print "Review this plan for risks and missing tests: ..."
```

For reviews and second opinions, include a no-write instruction in the prompt:

```bash
agy --print "Review the current diff. Do not modify files, run write commands, or apply patches. Return findings only."
```

This plugin also includes a small wrapper at `scripts/agy-print.sh` under the installed plugin root. Resolve an absolute wrapper path from the installed skill file location, not from the target repository being reviewed. For example, if this skill file is installed at `/absolute/path/to/codex-agy-plugin/skills/agy/SKILL.md`, the wrapper is `/absolute/path/to/codex-agy-plugin/scripts/agy-print.sh`. Prefer the wrapper when you want a default 10 minute timeout and simple `--add-dir` handling. Place wrapper options before the prompt; arguments after the prompt are included in the prompt text. Call `agy` directly when you need raw Antigravity CLI options the wrapper does not accept:

```bash
skill_path="/absolute/path/to/codex-agy-plugin/skills/agy/SKILL.md"
wrapper="$(cd "$(dirname "$skill_path")/../.." && pwd)/scripts/agy-print.sh"
"$wrapper" --add-dir /absolute/path/to/repo "Review the current diff."
```

If the prompt starts with `-`, pass `--` before the prompt:

```bash
skill_path="/absolute/path/to/codex-agy-plugin/skills/agy/SKILL.md"
wrapper="$(cd "$(dirname "$skill_path")/../.." && pwd)/scripts/agy-print.sh"
"$wrapper" -- "-starting prompt text"
```

Use a bounded timeout when the request may take longer:

```bash
agy --print "Review the current diff for bugs and regressions." --print-timeout 10m
```

Use `--add-dir` when Antigravity needs additional workspace roots:

```bash
agy --add-dir /absolute/path/to/repo --print "Analyze this repository slice. Do not modify files, run write commands, or apply patches. Return findings only."
```

Use interactive mode only when the user explicitly wants to continue in Antigravity:

```bash
agy --prompt-interactive "Start from this context: ..."
```

## Review Prompts

When the user asks for a broad review, pass a concrete review goal instead of a vague "review this" prompt. For example:

```text
Review the current diff for bugs, security concerns, edge cases, missing checks, and maintainability risks. Do not modify files, run write commands, or apply patches. Return findings only, with file paths when possible.
```

When the user wants release readiness, repeated review, or convergence, use a blocker-only prompt with an explicit exit condition:

```text
Release blocker review only. Review the current diff for issues that can break install, runtime, validation, CI, or plugin distribution. Report only High or Medium findings. Do not report Low, Optional, polish, naming, future hardening, or nice-to-have cleanup. If there are no High/Medium blockers, return exactly: APPROVED
```

Treat Low and Optional findings from a blocker-only review as backlog candidates, not as required follow-up unless the user explicitly asks to pursue them.

## Sandbox Handling

`agy` may create logs, start a local language-server process, or open network connections. If it fails with filesystem, logging, or localhost bind errors inside Codex sandboxing, explain the failure briefly and rerun only with the user's approval through Codex's normal escalation flow.

Do not use `--dangerously-skip-permissions` unless the user explicitly requests it for a trusted local workspace.

If `agy` tries to edit files during a review or second-opinion request, stop the run and inspect the diff. Revert only changes clearly introduced by that `agy` run; do not revert unrelated or pre-existing user changes. If the source of a change is unclear, ask the user before touching it.

## Response Contract

After `agy` returns:

1. Summarize Antigravity's useful findings.
2. Separate confirmed local facts from Antigravity suggestions.
3. Verify any proposed code change against local files before applying it.
4. If Antigravity's answer is unclear or too broad, narrow the prompt and run a follow-up rather than treating it as authoritative.
5. Do not apply Antigravity's suggested edits unless the user has explicitly moved the task from review/delegation into implementation.
