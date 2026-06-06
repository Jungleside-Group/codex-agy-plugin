# codex-agy-plugin

Antigravity CLI (`agy`) integration for OpenAI Codex.

This is a small Codex plugin that teaches Codex how to call the local Antigravity CLI for second opinions, planning, code review, and delegated analysis.

## Status

Experimental private MVP.

## Requirements

- Codex with plugin support.
- Antigravity CLI installed, authenticated, available as `agy`; this plugin is tested with `agy 1.0.6` and compatible print-mode arguments.
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
codex plugin marketplace add "$PWD"
codex plugin add codex-agy-plugin@codex-agy-plugin
```

After editing files under `plugins/codex-agy-plugin/`, rerun `codex plugin add codex-agy-plugin@codex-agy-plugin` so Codex refreshes its plugin cache. Start a new Codex thread after installing or reinstalling so the updated skill is loaded.

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
That path is for this repository checkout; installed Codex skills should resolve the wrapper from the plugin skill directory.
Place wrapper options before `PROMPT`; arguments after `PROMPT` are included in the prompt text.
Call `agy` directly when you need raw Antigravity CLI options that this wrapper does not accept.

Repository root `scripts/validate*.sh` files are development validators. `plugins/codex-agy-plugin/scripts/agy-print.sh` is the runtime wrapper shipped with the plugin.

```bash
plugins/codex-agy-plugin/scripts/agy-print.sh --print-timeout 15m "Review this repository. Do not modify files. Return findings only."
```

If the prompt begins with `-`, separate wrapper options from the prompt with `--`:

```bash
plugins/codex-agy-plugin/scripts/agy-print.sh -- "-starting prompt text"
```

For review and second-opinion requests, Codex should ask `agy` to return findings only and not modify files.

## Validate

```bash
scripts/validate.sh
```

Optional docs and local install validation:

```bash
scripts/validate-docs.sh
scripts/validate-install.sh
```

## Repository Layout

```text
.agents/plugins/marketplace.json
plugins/
  codex-agy-plugin/
    .codex-plugin/plugin.json
    LICENSE
    skills/agy/SKILL.md
    scripts/agy-print.sh
scripts/validate.sh
scripts/validate-docs.sh
scripts/validate-install.sh
```

## Notes

`agy` may need filesystem, network, or localhost bind permissions. If it fails inside a restricted Codex sandbox, approve the rerun only when the workspace and prompt are trusted.

## License

MIT
