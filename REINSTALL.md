# macOS Reinstall Runbook

This repository is the source of truth for rebuilding this Mac after an
Erase All Content and Settings reset. The goal is to restore selected data and
known-good configuration without restoring the accumulated contents of the old
home directory.

## Start Here

For a manual backup and restore, start with
[`docs/reinstall/manual.md`](docs/reinstall/manual.md) and follow it from top to
bottom. It is the only primary execution guide.

Do not begin with `backup.md`, `opencode.md`, or `zed.md`; those are focused
references used only when `manual.md` points to them. Track evidence and erase
gates in [`docs/reinstall/checklist.md`](docs/reinstall/checklist.md).

[`docs/reinstall/fast-path.md`](docs/reinstall/fast-path.md) is an optional
post-reset step inside the manual runbook. It restores this OpenCode session
early so the agent can help continue the remaining restore.

## Target State

- Apple Silicon Mac running the currently installed macOS release.
- New account short name: `quangdn` (`/Users/quangdn`).
- Shared and macOS dotfiles deployed with GNU Stow.
- Software installed from Homebrew whenever available.
- Mac App Store used only when an application has no maintained Homebrew cask.
- Python 3.12 and Go 1.26 available as global mise runtimes, with shared Go
  editor tools managed by mise's `go:` backend.
- Node.js, Rust, and other language runtimes declared by individual projects
  rather than selected globally.
- Only curated user data restored from encrypted Google Drive archives.
- OpenCode, native Zed Agent, and Zed external-agent sessions restored and
  rebound to the new project paths.

## Current Status

Completed in this stage:

- Reinstall decisions and runbook documentation.
- Curated Homebrew formula and cask declaration in [`Brewfile`](Brewfile).
- App Store fallback declaration in [`Brewfile.mas`](Brewfile.mas).
- Global mise declaration in
  [`shared/.config/mise/config.toml`](shared/.config/mise/config.toml).
- Sanitized OpenCode configuration in
  [`shared/.config/opencode/opencode.jsonc`](shared/.config/opencode/opencode.jsonc).
- A single manual backup and restore runbook in
  [`docs/reinstall/manual.md`](docs/reinstall/manual.md).
- An optional documentation-only OpenCode-first procedure in
  [`docs/reinstall/fast-path.md`](docs/reinstall/fast-path.md).
- Direct encrypted backup is in progress under run ID
  `20260731T185734Z-Quangs-MacBook-Air`.

Not completed yet:

- Remaining direct backup archives and the final verification manifest.
- Dynamic Kanata LaunchDaemon generation for the new home path.
- Active Fish cleanup and mise activation.
- OpenCode, Zed Agent, and Codex final state backup.
- Software installation, restore execution, or system reset.

## Reference Documents

- [`docs/reinstall/manual.md`](docs/reinstall/manual.md): the only primary,
  end-to-end manual backup and restore guide.
- [`docs/reinstall/checklist.md`](docs/reinstall/checklist.md): evidence and
  safety gates used by the manual guide.
- [`docs/reinstall/fast-path.md`](docs/reinstall/fast-path.md): optional early
  OpenCode recovery after reset.
- [`docs/reinstall/decisions.md`](docs/reinstall/decisions.md): agreed scope and
  decisions.
- [`docs/reinstall/software.md`](docs/reinstall/software.md): package sources,
  ownership, and exclusions.
- [`docs/reinstall/backup.md`](docs/reinstall/backup.md): retained data,
  encrypted archive design, and validation.
- [`docs/reinstall/opencode.md`](docs/reinstall/opencode.md): OpenCode session
  and state migration.
- [`docs/reinstall/zed.md`](docs/reinstall/zed.md): native Zed Agent and
  external-agent session migration.

## Execution Phases

1. Follow `docs/reinstall/manual.md` and complete the direct encrypted backup.
2. Finish and push the dotfiles runbook.
3. Archive `projects/` last, then close OpenCode and capture its final state.
4. Complete every verification and erase gate in `checklist.md`.
5. Stop and request explicit approval before erasing the Mac.
6. Use System Settings > General > Transfer or Reset > Erase All Content and
   Settings.
7. Create the `quangdn` account and optionally use the OpenCode fast path.
8. Continue the manual restore and final verification.

## Safety Rules

- Do not use Migration Assistant or restore the complete old home directory.
- Do not preserve data on another volume of the internal disk. Erase Assistant
  erases all volumes.
- Do not treat a Git remote as a backup of uncommitted, ignored, or unpushed
  project data.
- Do not store an age private identity, API token, SSH private key, or provider
  credential in Git.
- Do not erase with an incomplete Google Drive upload or an untested encrypted
  archive.
- Keep the encrypted pre-reset archive for at least 90 days after the rebuilt
  machine passes verification.

Apple's Erase All Content and Settings documentation:
<https://support.apple.com/en-us/102664>
