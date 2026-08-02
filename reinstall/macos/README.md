# macOS Reinstall

This repository rebuilds an Apple Silicon Mac with selected encrypted data,
without Migration Assistant or a whole-home restore.

## Start Here

Agents must read [`handoff.json`](handoff.json)
first and execute only its next action. The handoff is intentionally compact;
do not reread the full manual or a restored conversation unless its `read_set`
points there.

When no local `active-run` exists, the router deliberately requires a human to
identify whether this is the source Mac starting a backup or the fresh Mac
resuming a remote run. Never infer that distinction from an absent state file.

Humans starting a new run should read [`docs/manual.md`](docs/manual.md), review
[`config/archives.json`](config/archives.json),
then initialize the resumable workflow:

```sh
REINSTALL="$HOME/projects/dotfiles/reinstall/macos/bin/reinstall"
"$REINSTALL" init
"$REINSTALL" status
"$REINSTALL" continue
```

`continue` executes one safe stage at a time. It stops at human gates with
instructions and a `[d] Done` option. `status` and `continue` resume after a
logout, reboot, or agent change.

Verify the mechanics without touching the real home or Google Drive:

```sh
~/projects/dotfiles/reinstall/macos/tests/run.zsh
```

The fixture uses temporary homes, an ephemeral age identity, a local rclone
remote, and temporary Git repositories. It exercises backup, authentication,
resume, staged restore, no-overwrite behavior, and failure paths.

## State And Evidence

The tracked archive scope is [`config/archives.json`](config/archives.json). A
run resolves that scope into an immutable plan under:

```text
~/.local/state/dotfiles-reinstall/runs/<run-id>/
```

That private directory contains plans, receipts, reports, conflict summaries,
checksums, append-only events, and current state. Markdown checkboxes are not
live execution state.

Before erase, finalization uploads a compact `resume.json`, `manifest.json`, and
`SHA256SUMS` beside the encrypted archives. After erase, clone the recorded
dotfiles commit and recover state with:

```sh
REINSTALL="$HOME/projects/dotfiles/reinstall/macos/bin/reinstall"
"$REINSTALL" resume 'gdrive:mac-reinstall/<run-id>' '<independently-stored-manifest-sha256>'
"$REINSTALL" continue
```

## Human Boundaries

The script never performs or silently approves:

- Erase All Content and Settings
- Account authentication or two-factor recovery
- FileVault recovery-key storage
- Browser, Apple, or Raycast synchronization acceptance
- Accessibility, Input Monitoring, Driver Extension, or other privacy approval
- Restoration of old authentication tokens by default
- Destructive cache cleanup without an unchanged reviewed plan
- Final acceptance of representative restored files and sessions

Noninteractive execution exits with status `20` at a human gate and prints the
exact resume command.

## Documents

- [`manual.md`](docs/manual.md): automated sequence, human gates, and
  manual fallback commands
- [`checklist.md`](docs/checklist.md): reusable gate reference, not
  live state
- [`backup.md`](docs/backup.md): archive and encryption rationale
- [`opencode.md`](docs/opencode.md): OpenCode capture and migration
- [`zed.md`](docs/zed.md): Zed and Codex capture and migration
- [`fast-path.md`](docs/fast-path.md): optional early OpenCode restore
- [`decisions.md`](docs/decisions.md): durable scope decisions
- [`history/`](docs/history/): completed run summaries

## Safety Rules

- Keep every selected archive encrypted with age. Google Drive encryption alone
  is not sufficient for browser, agent, credential, project, or personal data.
- Never modify an original encrypted archive; migrate restored copies only.
- Never overwrite the fresh GitHub dotfiles clone from `projects.tar.zst.age`.
- Never restore the complete old home or `~/Library` directory.
- Never create an old-home compatibility symlink.
- Never use `brew bundle cleanup` in this workflow.
- Keep encrypted originals for at least 90 days after final acceptance.
