# codex-agy-plugin

Antigravity CLI (`agy`) integration for OpenAI Codex.

This is a small Codex plugin that teaches Codex how to call the local Antigravity CLI for second opinions, planning, code review, and delegated analysis.

## Status

Experimental private MVP.

## Requirements

- Codex with plugin support.
- Antigravity CLI installed, authenticated, and available as `agy`.
- A trusted local workspace. Do not send secrets or unrelated private data to delegated prompts.

Check the local CLI:

```bash
command -v agy
agy --version
agy --help
```

## Install From GitHub

Add this repository as a Codex plugin marketplace, then install the plugin:

```bash
codex plugin marketplace add sysCat64/codex-agy-plugin --ref main
codex plugin add codex-agy-plugin@codex-agy-plugin
```

For local development:

```bash
codex plugin marketplace add /Users/martha/Documents/Repositories/codex-agy-plugin
codex plugin add codex-agy-plugin@codex-agy-plugin
```

Start a new Codex thread after installing or reinstalling so the plugin's skill is loaded.

## Usage

Ask Codex to use Antigravity:

```text
Use agy to review the current diff.
```

```text
Ask Antigravity for a second opinion on this implementation plan.
```

```text
Delegate this bug investigation to agy and summarize what it finds.
```

Codex will use `agy --print` for non-interactive runs by default.

The plugin also ships `plugins/codex-agy-plugin/scripts/agy-print.sh`, a tiny wrapper around `agy --print --print-timeout 10m`.

## Repository Layout

```text
.agents/plugins/marketplace.json
plugins/
  codex-agy-plugin/
    .codex-plugin/plugin.json
    skills/agy/SKILL.md
    scripts/agy-print.sh
```

## Notes

`agy` may need filesystem, network, or localhost bind permissions. If it fails inside a restricted Codex sandbox, approve the rerun only when the workspace and prompt are trusted.

## License

MIT
