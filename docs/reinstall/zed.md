# Zed Agent State Migration

This is a Zed/Codex-specific reference. Start and track execution in
[`manual.md`](manual.md).

Zed's Thread History contains sessions owned by different agents. Preserving
the Zed databases alone is sufficient for native Zed Agent threads, but not for
External Agent threads whose content is owned by the external agent.

## Planning Snapshot

Observed on 2026-07-31:

| Item | Value |
| --- | --- |
| Zed version | `1.13.1` |
| Native Zed Agent threads | 16 |
| Native thread database | About 15 MB |
| Zed sidebar thread entries | 103 |
| Native sidebar entries | 16 |
| `codex-acp` sidebar entries | 87 |
| Zed stable database and WAL | About 36 MB |
| Codex version | `0.141.0` |
| Codex sessions | 103 |
| Codex state | About 221 MB |
| Codex session JSONL files | About 142 MB |

The final backup tooling must inventory live counts and versions rather than
using these planning values as restore targets.

All native Zed thread folder paths, all Zed sidebar paths, and all Codex
session working directories currently reference `/Users/quang-dang`. They must
be rebound to `/Users/quangdn` in restore copies.

## Ownership Boundaries

| History type | Content owner | Required backup |
| --- | --- | --- |
| Zed Agent | Zed | Native `threads.db` plus portable extracts |
| Codex external agent | Codex | Codex session store plus Zed sidebar metadata |
| Other future external agents | External agent | That agent's native session store plus Zed metadata |

Zed documents that External Agents own their own runtime, authentication,
configuration, and session data. Zed's sidebar rows are an index, not a copy of
the external conversation.

## Zed State Locations

| Path | Handling |
| --- | --- |
| `~/Library/Application Support/Zed/threads/threads.db` | Required native Zed Agent history |
| `~/Library/Application Support/Zed/db/0-stable/db.sqlite` | Thread sidebar metadata emergency backup |
| `~/Library/Application Support/Zed/db/0-global/db.sqlite` | Not required for thread content |
| `~/.config/zed` | Already tracked in this repository |
| `~/Library/Application Support/Zed/extensions` | Regenerate |
| `~/Library/Application Support/Zed/external_agents` | Regenerate from the ACP registry |
| `~/Library/Application Support/Zed/languages` | Regenerate |
| `~/Library/Application Support/Zed/node` | Regenerate |
| `~/Library/Application Support/Zed/prettier` | Regenerate |
| `~/Library/Application Support/Zed/debug_adapters` | Regenerate |
| `~/Library/Caches/Zed` | Exclude |

Do not archive the full 1.9 GB Zed support directory. The native thread and
metadata databases are small; downloaded agent packages and language tooling
account for nearly all remaining space.

## Codex State Locations

| Path | Handling |
| --- | --- |
| `~/.codex/sessions` | Required conversation JSONL files |
| `~/.codex/state_5.sqlite` | Required thread index and working directories |
| `~/.codex/history.jsonl` | Preserve |
| `~/.codex/config.toml` | Preserve encrypted; review before restoring |
| `~/.codex/memories*` and `~/.codex/goals*` | Preserve |
| `~/.codex/rules` and `~/.codex/skills` | Preserve |
| `~/.codex/auth.json` | Emergency encrypted backup only; reauthenticate by default |
| `~/.codex/cache`, logs, and temporary directories | Exclude |

Codex session files and databases can contain prompts, source excerpts,
command output, working directory paths, repository metadata, and credentials.
Treat the entire archive as sensitive.

## Backup Layers

### Native Zed Threads

Zed 1.13.1 has no CLI bulk-export or import command for native Agent threads.
The supported UI can open one thread as Markdown, but Markdown is a
human-readable fallback and cannot recreate complete thread state.

Create both:

1. A consistent SQLite backup of `threads/threads.db` for actual restoration.
2. A portable encrypted extract of each row's decompressed JSON, with one file
   per thread and a manifest containing ID, title, dates, folder paths, data
   format, and checksum.

The row payloads are zstd-compressed JSON. Portable extraction is for
inspection and future migration; raw database restoration remains the primary
method because Zed has no supported JSON importer.

Optionally open important threads as Markdown in Zed for a second
human-readable representation.

### Zed Sidebar Metadata

Create a consistent backup of the stable Zed database and a separate encrypted
JSON or SQL export of these thread-related tables:

- `sidebar_threads`
- `archived_git_worktrees`
- `thread_archived_worktrees`

Do not restore the complete stable database into the new profile by default;
it also contains editor, workspace, terminal, navigation, and other state that
the clean reinstall is intended to discard.

### Codex Sessions

Create a curated encrypted Codex archive containing session data, state
databases, history, memories, rules, skills, and configuration. Keep auth only
inside the emergency payload and sign in again after reset.

The final backup script must:

- Count Codex thread-index rows and session JSONL files.
- Check every Codex SQLite database for integrity.
- Record the Codex version.
- Report every path containing the old home prefix.
- Keep an untouched original archive before any migration.

## Consistent Backup Procedure

1. Finish active prompts and wait for every Zed and Codex agent to stop.
2. Quit Zed completely.
3. Confirm no Zed, Codex, or ACP process is running.
4. Use SQLite's online backup facility for `threads.db`, the stable Zed
   database, and Codex databases; do not copy only a live main database while
   a WAL is active.
5. Run `PRAGMA integrity_check` on every copied database.
6. Produce native Zed portable extracts and thread metadata manifests.
7. Archive the curated Codex state.
8. Encrypt Zed and Codex archives with age.
9. Upload with rclone and apply the same checksum and test-decryption gates as
   the other archives.

## Path Migration

Never modify the encrypted originals. Perform migration only in a restored
working copy.

Native Zed path-bearing data includes:

- `threads.folder_paths`
- Project snapshots and sandbox grants inside compressed thread JSON
- `sidebar_threads.folder_paths`
- `sidebar_threads.main_worktree_paths`
- Archived-worktree paths, if present

Codex path-bearing data includes:

- `state_5.sqlite` columns `threads.cwd` and `threads.rollout_path`
- Session JSONL fields containing the old working directory
- Configuration or shell snapshots that explicitly contain the old home

The migration script must parse structured data and replace only the exact
`/Users/quang-dang` prefix with `/Users/quangdn`. Do not use a broad textual
replacement over encrypted archives or SQLite files.

Old sandbox write grants should not be widened to the new home automatically.
Leave them pointing to the nonexistent old path or clear them, then let Zed ask
for new approvals.

## Restore Order

1. Restore projects and workspaces under `/Users/quangdn`.
2. Install the recorded Zed and Codex versions when practical.
3. Start Zed once only if needed to create its data directories, then quit it.
4. Restore a migrated copy of the native `threads.db` before opening Thread
   History.
5. Let Zed migrate native thread metadata into the new sidebar database.
6. Restore and migrate the curated Codex state.
7. Reauthenticate Codex instead of restoring `auth.json` by default.
8. Confirm `codex resume --all` lists the restored sessions.
9. Install Codex from Zed's ACP Registry.
10. In Zed Thread History, use **Import Threads** for Codex. Re-importing is
    documented as safe because existing sessions are skipped.
11. Use the sidebar metadata export only to recover titles, archive status, or
    entries that native migration and external-agent import did not recreate.
12. Keep the raw stable database untouched as an emergency reference.

## Isolated Validation

Zed supports `--user-data-dir`, so validate the restored databases in an
isolated profile before replacing any live new-machine state:

```sh
zed --user-data-dir /path/to/zed-restore-test
```

The validation profile must use copies of restored data, not the encrypted
originals.

## Validation

- Native Zed thread count matches the final manifest.
- Every native row decompresses and parses as JSON.
- Native and stable SQLite copies pass integrity checking.
- Codex session file count and thread-index count match the final manifest.
- `codex resume --all` lists restored sessions under `/Users/quangdn`.
- Zed Thread History shows native Zed Agent threads.
- Zed's Codex import recreates the expected external-agent history.
- Important native threads can open as Markdown.
- Representative native and Codex sessions can continue.
- No restored session grants access to the new home without a new approval.
- Zed and Codex archives remain encrypted and retained for at least 90 days.

References:

- <https://zed.dev/docs/ai/agent-panel>
- <https://zed.dev/docs/ai/external-agents#importing-threads>
