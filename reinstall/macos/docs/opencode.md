# OpenCode State Migration

This is an OpenCode-specific reference. Start and track execution in
[`manual.md`](manual.md).

OpenCode sessions must survive a reinstall and any account path change. Read
`source_home` and `target_home` from the authenticated run manifest; the 2026
run migrated `/Users/quang-dang` to `/Users/quangdn`, but a later run may not.

## Optional Fast-Path Session Restore

The primary execution guide is [`manual.md`](manual.md). At its optional
post-reset branch, follow [`fast-path.md`](fast-path.md) to reinstall OpenCode
and manually import the current restore-planning session early.

The fast path is documentation only and uses the same portable export archive
as the full session restore. Importing from
`/Users/quangdn/projects/dotfiles` rebinds the session to the new home. The
restored conversation, final repository commit, backup manifest, and checklist
give the resumed agent enough context to continue. The raw state archive below
remains an emergency layer.

## Planning Snapshot

Observed on 2026-07-31:

| Item | Value |
| --- | --- |
| OpenCode version | `1.18.10` |
| Sessions | 127 |
| Projects | 9 |
| Messages | 10,249 |
| Parts | 46,691 |
| `~/.local/share/opencode` | About 715 MB |
| SQLite database | About 655 MB |

These numbers are not restore targets. The final backup tooling must inventory
the live state dynamically because this planning session and later sessions
will change them.

## State Locations

| Path | Handling |
| --- | --- |
| `~/.config/opencode/opencode.jsonc` | Track sanitized configuration in this repo |
| `~/.config/opencode/node_modules` | Regenerate; do not back up |
| `~/.cache/opencode` | Regenerate; do not back up |
| `~/.local/share/opencode/opencode.db` | Consistent raw emergency backup |
| `~/.local/share/opencode/storage` | Preserve for legacy/session state |
| `~/.local/share/opencode/snapshot` | Preserve for session snapshots and reverts |
| `~/.local/share/opencode/tool-output` | Preserve for complete historical tool output |
| `~/.local/share/opencode/auth.json` | Encrypt in emergency backup; reauthenticate by default |
| `~/.local/share/opencode/log` | Exclude |
| `~/.local/share/opencode/bin` | Regenerate |

The database and exports may contain prompts, source excerpts, command output,
account metadata, and credentials. Treat every OpenCode archive as sensitive.

## Two Recovery Layers

### Portable Session Exports

Use the supported OpenCode CLI to export every session to JSON. Generate a
manifest containing:

- Session ID
- Session title only inside the encrypted payload
- Original project worktree
- Original session directory
- Relative directory beneath the run's recorded `source_home`
- Export filename
- Export checksum
- OpenCode version
- Final dotfiles branch and commit used by the restore-planning session

The executable fallback in `manual.md` obtains the full session list
dynamically and fails if any session cannot be exported. Keep unsanitized
exports for actual recovery, but encrypt them immediately. Sanitized exports
are optional audit artifacts and are not sufficient for exact recovery.

OpenCode's importer assigns an imported session to the project and directory
from which `opencode import` is run. After restoring projects, import each JSON
while inside its mapped directory under `/Users/quangdn`. This avoids editing
the old absolute path inside the export.

### Raw Emergency State

The raw layer preserves data not guaranteed by JSON export, including snapshot
and internal state. It is a fallback, not the first restore method.

Before creating it:

1. Finish and exit this and all other OpenCode sessions.
2. Confirm no OpenCode server, TUI, or background process remains.
3. Record `opencode --version` and `opencode db path`.
4. Use SQLite's online backup facility or an equivalent consistent database
   snapshot; do not copy only the live main database while a WAL is active.
5. Package the database backup with `storage`, `snapshot`, and `tool-output`.
6. Include `auth.json` only in the encrypted emergency payload.
7. Check SQLite integrity on the copied database before encryption.

## Restore Order

1. Clone `~/projects/dotfiles` from GitHub and optionally use `fast-path.md` to
   import the restore-planning session early.
2. Restore the remaining project and workspace archives.
3. Keep the fresh GitHub clone of `~/projects/dotfiles` rather than replacing
   it from the old projects archive.
4. Initially use the recorded backup version if the current release cannot
   import the exports cleanly.
5. Deploy the sanitized global configuration from this repository.
6. Do not restore `auth.json`; keep the provider login created by the fast path.
7. Import every remaining session JSON from its mapped project directory.
8. Compare imported session and message counts with the encrypted manifest.
9. Open representative sessions from each project and confirm history and tool
   output are usable.
10. Retain the raw archive untouched until the portable restore is accepted.

## Raw Fallback Path Migration

The 2026 snapshot used `/Users/quang-dang`. A raw database restore requires a
controlled path migration in a copy only when `source_home` differs from
`target_home`. Relevant columns include:

- `project.worktree`
- `project_directory.directory`
- `session.directory`
- `workspace.directory`

Legacy JSON under `storage` and snapshot metadata may also contain absolute
paths. Any raw restore helper must discover and report every old-prefix
occurrence before changing it, replace only the exact old home prefix, run an
integrity check, and retain the untouched database backup.

Do not create a compatibility symlink for an old source home.

## Validation

- The final export count equals the final session inventory count.
- Every export has a project mapping and checksum.
- The raw SQLite backup passes `PRAGMA integrity_check`.
- The age archives decrypt and list successfully after download.
- Imported sessions bind to `/Users/quangdn`, not the old home.
- Representative sessions can continue with `opencode --session <id>`.
- Provider login works without restoring old credential files.
- The encrypted raw archive is retained for at least 90 days.

OpenCode CLI export/import reference:
<https://opencode.ai/docs/cli/#export>
