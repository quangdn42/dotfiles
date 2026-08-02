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

The 2026 snapshot referenced `/Users/quang-dang`. Read `source_home` and
`target_home` from the authenticated run manifest and rebind paths in restore
copies only when those values differ.

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

The manual capture adapter must:

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

## Executable Capture Fallback

Use this when the manual capture adapters are reached. Run in zsh after quitting
Zed, Codex, and every ACP process. Read all run values from state:

```zsh
REINSTALL="$HOME/projects/dotfiles/reinstall/macos/bin/reinstall"
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
AGE_RECIPIENT="$(jq -r '.age_recipient' "$RUN_DIR/run.json")"

if pgrep -ifl 'Zed|Codex|codex|ACP'; then
  print -u2 -- 'Quit Zed, Codex, and ACP processes before capture.'
  exit 1
fi
```

### Native Zed Capture

Create consistent SQLite copies and a portable JSON extract of every native
thread. The database payload is zstd-compressed JSON:

```zsh
ZED_SOURCE="$HOME/Library/Application Support/Zed"
ZED_CAPTURE="$RUN_DIR/staging/zed-capture"
ZED_STAGE="$ZED_CAPTURE/zed-agent"
test ! -e "$ZED_CAPTURE"
mkdir -p "$ZED_STAGE/portable"
chmod 700 "$ZED_CAPTURE"

sqlite3 "$ZED_SOURCE/threads/threads.db" ".backup '$ZED_STAGE/threads.db'"
sqlite3 "$ZED_SOURCE/db/0-stable/db.sqlite" ".backup '$ZED_STAGE/zed-stable.db'"
test "$(sqlite3 "$ZED_STAGE/threads.db" 'PRAGMA integrity_check;')" = ok
test "$(sqlite3 "$ZED_STAGE/zed-stable.db" 'PRAGMA integrity_check;')" = ok

sqlite3 -json "$ZED_STAGE/threads.db" '
SELECT id, summary, updated_at, created_at, data_type, parent_id,
       worktree_branch, folder_paths, folder_paths_order, hex(data) AS data_hex
FROM threads ORDER BY updated_at;
' > "$ZED_STAGE/thread-rows.json"

: > "$ZED_STAGE/portable-checksums.ndjson"
for row in ${(f)"$(jq -c '.[]' "$ZED_STAGE/thread-rows.json")"}; do
  id="$(jq -r '.id' <<<"$row")"
  [[ "$id" =~ '^[A-Za-z0-9._-]+$' ]] || exit 1
  jq -r '.data_hex' <<<"$row" | xxd -r -p |
    zstd --decompress --quiet --stdout > "$ZED_STAGE/portable/$id.json"
  jq -e . "$ZED_STAGE/portable/$id.json" >/dev/null
  sha="$(shasum -a 256 "$ZED_STAGE/portable/$id.json" | cut -d ' ' -f 1)"
  jq -cn --arg id "$id" --arg filename "portable/$id.json" --arg sha256 "$sha" \
    '{id:$id,filename:$filename,sha256:$sha256}' \
    >> "$ZED_STAGE/portable-checksums.ndjson"
done

jq -s '.' "$ZED_STAGE/portable-checksums.ndjson" \
  > "$ZED_STAGE/portable-checksums.json"
jq -n --slurpfile rows "$ZED_STAGE/thread-rows.json" \
  --slurpfile checksums "$ZED_STAGE/portable-checksums.json" \
  --arg created_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  '{schema_version:1,created_at:$created_at,
    threads:[$rows[0][] | del(.data_hex)],portable:$checksums[0]}' \
  > "$ZED_STAGE/threads-manifest.json"

sqlite3 "$ZED_STAGE/zed-stable.db" \
  ".output '$ZED_STAGE/sidebar-thread-metadata.sql'" \
  '.dump sidebar_threads' '.output stdout'
```

Encrypt atomically and register it with the common pipeline:

```zsh
ZED_ARCHIVE="$RUN_DIR/zed-agent.tar.zst.age"
tar -C "$ZED_CAPTURE" -cpf - zed-agent |
  zstd --threads=0 --quiet --stdout |
  age --recipient "$AGE_RECIPIENT" --output "$ZED_ARCHIVE.partial"
mv "$ZED_ARCHIVE.partial" "$ZED_ARCHIVE"
"$REINSTALL" backup register zed-agent "$ZED_ARCHIVE"
```

### Codex Capture

Copy curated state only after Codex is stopped. Replace copied live SQLite files
with online backups and exclude caches, logs, and transient WAL files:

```zsh
CODEX_CAPTURE="$RUN_DIR/staging/codex-capture"
CODEX_STAGE="$CODEX_CAPTURE/codex-agent/.codex"
test ! -e "$CODEX_CAPTURE"
mkdir -p "$CODEX_STAGE"
chmod 700 "$CODEX_CAPTURE"

rsync -aAX \
  --exclude='cache/' --exclude='log/' --exclude='logs/' \
  --exclude='*.sqlite' --exclude='*.sqlite-shm' --exclude='*.sqlite-wal' \
  "$HOME/.codex/" "$CODEX_STAGE/"

for database in "$HOME/.codex"/*.sqlite(N); do
  sqlite3 "$database" ".backup '$CODEX_STAGE/${database:t}'"
  test "$(sqlite3 "$CODEX_STAGE/${database:t}" 'PRAGMA integrity_check;')" = ok
done

session_files="$(find "$CODEX_STAGE/sessions" -type f -name '*.jsonl' 2>/dev/null | wc -l | tr -d ' ')"
thread_rows="$(sqlite3 "$CODEX_STAGE/state_5.sqlite" 'SELECT COUNT(*) FROM threads;')"
jq -n --arg created_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  --arg codex_version "$(codex --version)" \
  --argjson session_files "$session_files" --argjson thread_rows "$thread_rows" \
  '{schema_version:1,created_at:$created_at,codex_version:$codex_version,
    session_files:$session_files,thread_rows:$thread_rows,
    auth_restore_default:false}' > "$CODEX_CAPTURE/codex-agent/manifest.json"

CODEX_ARCHIVE="$RUN_DIR/codex-agent.tar.zst.age"
tar -C "$CODEX_CAPTURE" -cpf - codex-agent |
  zstd --threads=0 --quiet --stdout |
  age --recipient "$AGE_RECIPIENT" --output "$CODEX_ARCHIVE.partial"
mv "$CODEX_ARCHIVE.partial" "$CODEX_ARCHIVE"
"$REINSTALL" backup register codex-agent "$CODEX_ARCHIVE"
```

The registered archive remains encrypted, but `auth.json` is still emergency
material and must not be restored by default. After both registrations, return
to `reinstall continue`; the `agent_state` gate binds approval to their archive
checksums.

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

Migration must parse structured data and replace only the exact recorded
`source_home` prefix with `target_home`. Do not use a broad textual replacement
over encrypted archives or SQLite files.

Old sandbox write grants should not be widened to the new home automatically.
Leave them pointing to the nonexistent old path or clear them, then let Zed ask
for new approvals.

## Restore Order

1. Restore projects and workspaces under `/Users/quangdn`.
2. Install the recorded Zed and Codex versions when practical.
3. Start Zed once only if needed to create its data directories, then quit it.
4. Restore a migrated copy of the native `threads.db` before opening Thread
   History.
5. Selectively merge the migrated native-agent rows from `sidebar_threads` into
   the initialized fresh stable database. Do not rely on Zed to recreate every
   visible sidebar row from `threads.db` alone.
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
