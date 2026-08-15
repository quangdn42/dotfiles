# Automated Backup And Restore

This is the end-to-end human guide and the fallback when automation stops. Live
state is stored under `~/.local/state/dotfiles-reinstall`; it is not stored in
this document or inferred from [`checklist.md`](checklist.md).

Agents must begin with [`handoff.json`](../handoff.json) and read only the files or
anchors in its `read_set`. Humans starting a new run should review this file,
[`config/archives.json`](../config/archives.json),
and the durable decisions in [`decisions.md`](decisions.md).

Use `/bin/zsh` for the complete terminal workflow. Do not change shells midway
through a run. Do not use Migration Assistant or restore the complete old home
or `~/Library` directory.

## Start A New Run

Deploy or invoke the tracked executable, initialize one timestamped run, and
let it report one safe next action at a time:

```sh
REINSTALL="$HOME/projects/dotfiles/reinstall/macos/bin/reinstall"
"$REINSTALL" init
"$REINSTALL" status
"$REINSTALL" continue
```

The executable always runs directly from the cloned repository:

```sh
REINSTALL="$HOME/projects/dotfiles/reinstall/macos/bin/reinstall"
```

Run `continue` repeatedly. It stops at human gates, prints exact instructions,
and offers `[d] Done`, `[l] Later and stop`, or `[q] Quit`. Noninteractive runs
exit with status `20` and print the resume command. A logout, reboot, or agent
change does not lose progress:

```sh
"$REINSTALL" status
"$REINSTALL" continue
```

## Pre-Erase Sequence

The state machine executes these stages in order:

1. `doctor pre-erase` checks macOS, tools, archive definitions, and the age
   identity/recipient pair.
2. `recovery_accounts` and `recovery_age` require independent human recovery
   acceptance.
3. `cleanup plan` writes an immutable candidate and Downloads inventory.
4. `cleanup_review` stops for human review and binds approval to the plan hash.
5. `cleanup apply` verifies every candidate is unchanged before deleting any
   candidate, then writes a receipt. Downloads are never deleted automatically.
6. `backup plan all` resolves the tracked archive definition into exact plans,
   inventories, counts, exclusions, and plan checksums.
7. `archive_plan_review` binds human approval to all plan hashes.
8. `backup create all` atomically creates and locally validates filesystem
   archives. It stops when a required application is still running.
9. OpenCode, Zed, and Codex use the focused manual capture procedures below;
   register each result, then pass `agent_state` bound to their checksums.
10. `backup upload all` refuses to overwrite any different remote object.
11. `backup verify all` decrypts/lists locally and hashes every complete remote
    stream.
12. `representative_restore` and `sync_only_recovery` require human acceptance.
13. `backup finalize` proves dotfiles are clean and pushed, re-verifies required
    archives, then creates and remotely verifies `manifest.json`,
    `SHA256SUMS`, and `resume.json`.
14. `erase_approval` requires explicit human approval. The script never erases
    the Mac.

The authoritative archive scope is
[`archives.json`](../config/archives.json). It explicitly
records encrypted archives, manual capture adapters, sync-only coverage, and
intentional omissions. Do not maintain a second mutable archive table here.

Manual agent captures remain application-specific:

```sh
"$REINSTALL" backup register opencode-exports /path/to/opencode-exports.tar.zst.age
"$REINSTALL" backup register opencode-raw /path/to/opencode-raw.tar.zst.age
"$REINSTALL" backup register zed-agent /path/to/zed-agent.tar.zst.age
"$REINSTALL" backup register codex-agent /path/to/codex-agent.tar.zst.age
```

Use [`opencode.md`](opencode.md) and [`zed.md`](zed.md) for consistent database
capture and version-specific validation.

## Required Human Recovery Access

Before approving erase, verify without relying only on this Mac:

- Apple Account and App Store login
- Bitwarden login and two-factor recovery
- Google Drive login and rclone authorization
- GitHub login and repository access
- The age private identity and a successful test decryption
- The final run ID, manifest digest, and remote backup location

Store the final manifest digest independently, such as in a Bitwarden secure
note. Never record the private age identity in Git or run evidence.

## Manual Cleanup Fallback

If orchestration fails, generate the same reviewed plan directly:

```sh
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
HELPER="$HOME/projects/dotfiles/reinstall/macos/lib/reinstall_helper.py"

python3 "$HELPER" cleanup-plan \
  --home "$HOME" \
  --output "$RUN_DIR/plans/cleanup.json"
shasum -a 256 "$RUN_DIR/plans/cleanup.json"
```

Review `.candidates` and `.downloads`. Do not delete a path merely because its
name resembles a cache. Applying the plan still requires an interactive exact
confirmation through `reinstall cleanup apply`; this prevents a partial or
changed-plan cleanup.

## Manual Archive Fallback

Use this only for a failed generic archive stage. Obtain exact relative sources
and exclusions from the reviewed generated plan, not from memory:

```sh
set -o pipefail
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
AGE_IDENTITY="$HOME/.config/age/reinstall-key.txt"
AGE_RECIPIENT="$(age-keygen -y "$AGE_IDENTITY")"
mkdir -p "$RUN_DIR/fallback"
ARCHIVE="$RUN_DIR/fallback/<archive>.tar.zst.age"

rm -f "$ARCHIVE.partial"
if tar --acls --xattrs <exclusions> -C "$HOME" -cpf - <relative-sources> |
  zstd --threads=0 --quiet --stdout |
  age --recipient "$AGE_RECIPIENT" --output "$ARCHIVE.partial"
then
  mv "$ARCHIVE.partial" "$ARCHIVE"
else
  rm -f "$ARCHIVE.partial"
  exit 1
fi
```

Then use the script to validate, upload, and verify the exact artifact. It
writes metadata and receipts consistently:

```sh
"$REINSTALL" backup register <archive-id> "$ARCHIVE"
"$REINSTALL" backup upload <archive-id>
"$REINSTALL" backup verify <archive-id>
```

Do not overwrite a remote object after an interrupted attempt. The upload stage
accepts an existing object only when its complete stream checksum matches.

## Representative Pre-Erase Restore

After remote verification, test representative personal, project, credential,
and agent archives from the remote copy rather than the local artifact. Use a
private temporary directory and repeat this block for selected archive IDs:

```sh
DOTFILES="$HOME/projects/dotfiles"
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
TEST_ROOT="$(mktemp -d "$HOME/reinstall-restore-test.XXXXXX")"
chmod 700 "$TEST_ROOT"
HELPER="$DOTFILES/reinstall/macos/lib/reinstall_helper.py"
AGE_IDENTITY="$(jq -r '.age_identity' "$RUN_DIR/run.json")"
ARCHIVE_ID='<personal-or-projects-or-credentials-or-opencode-exports>'
ARCHIVE_NAME="$(jq -r --arg id "$ARCHIVE_ID" \
  '.archives[] | select(.id == $id) | .filename' \
  "$DOTFILES/reinstall/macos/config/archives.json")"
REMOTE="$(jq -r '.remote' "$RUN_DIR/run.json")"

rclone copyto "$REMOTE/$ARCHIVE_NAME" "$TEST_ROOT/$ARCHIVE_NAME"
expected_sha="$(jq -r '.sha256' "$RUN_DIR/archives/$ARCHIVE_ID.metadata.json")"
test "$(shasum -a 256 "$TEST_ROOT/$ARCHIVE_NAME" | cut -d ' ' -f 1)" = "$expected_sha"

age --decrypt --identity "$AGE_IDENTITY" "$TEST_ROOT/$ARCHIVE_NAME" |
  zstd --decompress --quiet --stdout |
  python3 "$HELPER" validate-tar \
    --archive-sha256 "$expected_sha" \
    --output "$TEST_ROOT/$ARCHIVE_ID.listing.json"

mkdir -p "$TEST_ROOT/$ARCHIVE_ID"
age --decrypt --identity "$AGE_IDENTITY" "$TEST_ROOT/$ARCHIVE_NAME" |
  zstd --decompress --quiet --stdout |
  tar -xpf - -C "$TEST_ROOT/$ARCHIVE_ID"
```

Open representative documents and media, inspect an SSH public key without
using a private key, validate an exported agent session, and run `git fsck
--full` in representative restored repositories. Keep the temporary test until
the `representative_restore` gate is passed, then remove it manually.

## Detailed Manual Agent Capture Fallback

The following pre-erase sections preserve the executable OpenCode capture used
by the previous run. They are a fallback for the manual capture adapters, not
live run status. Replace every placeholder from `run.json`; never reuse a prior
run ID, recipient, planning session ID, or source home.

## Final Pre-Erase Steps

After generic archives are created and the repository is pushed, archive
`projects` last. Finish and close every OpenCode process before this final
manual capture. The script handles registration, metadata, upload, verification,
manifest construction, and cross-erase resume state afterward.

### Final OpenCode Capture

Use a normal zsh terminal. Set `PLANNING_SESSION_ID` to the current handoff
session if one must be resumed early; otherwise leave it empty:

```zsh
set -o pipefail
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
AGE_IDENTITY="$(jq -r '.age_identity' "$RUN_DIR/run.json")"
AGE_RECIPIENT="$(jq -r '.age_recipient' "$RUN_DIR/run.json")"
OPENCODE_DB="$(opencode db path)"
OPENCODE_STAGE="$RUN_DIR/staging/opencode-final"
PLANNING_SESSION_ID='<current-session-id-or-empty>'

if pgrep -ifl opencode; then
  print -u2 -- 'Quit every OpenCode process before final capture.'
  return 1
fi
test ! -e "$OPENCODE_STAGE"
mkdir -p "$OPENCODE_STAGE/exports" "$OPENCODE_STAGE/raw"
chmod 700 "$OPENCODE_STAGE"
```

Inventory directly from SQLite, export every session, and record each export
filename and checksum inside encrypted staging:

```zsh
sqlite3 -readonly -json "$OPENCODE_DB" '
SELECT s.id, s.project_id, s.parent_id, s.directory, s.title, s.version,
       s.time_created, s.time_updated, p.worktree AS project_worktree
FROM session AS s
LEFT JOIN project AS p ON p.id = s.project_id
ORDER BY s.time_updated;
' > "$OPENCODE_STAGE/sessions.json"

jq -e 'all(.[]; (.id | type == "string") and (.directory | type == "string"))' \
  "$OPENCODE_STAGE/sessions.json" >/dev/null

for session_id in ${(f)"$(jq -r '.[].id' "$OPENCODE_STAGE/sessions.json")"}; do
  export_file="$OPENCODE_STAGE/exports/$session_id.json"
  opencode export "$session_id" > "$export_file"
  jq -e --arg id "$session_id" \
    '.info.id == $id and (.messages | type == "array")' "$export_file" >/dev/null
  export_sha="$(shasum -a 256 "$export_file" | cut -d ' ' -f 1)"
  jq -cn --arg id "$session_id" --arg filename "exports/$session_id.json" \
    --arg sha256 "$export_sha" \
    '{session_id:$id,export_filename:$filename,sha256:$sha256}' \
    >> "$OPENCODE_STAGE/export-checksums.ndjson"
done

jq -s '.' "$OPENCODE_STAGE/export-checksums.ndjson" \
  > "$OPENCODE_STAGE/export-checksums.json"
expected_sessions="$(jq 'length' "$OPENCODE_STAGE/sessions.json")"
exported_sessions="$(find "$OPENCODE_STAGE/exports" -name '*.json' -type f | wc -l | tr -d ' ')"
test "$expected_sessions" = "$exported_sessions"
if [[ -n "$PLANNING_SESSION_ID" ]]; then
  jq -e --arg id "$PLANNING_SESSION_ID" '.[] | select(.id == $id)' \
    "$OPENCODE_STAGE/sessions.json" >/dev/null
fi
```

Build the portable archive atomically:

```zsh
jq -n \
  --slurpfile sessions "$OPENCODE_STAGE/sessions.json" \
  --slurpfile checksums "$OPENCODE_STAGE/export-checksums.json" \
  --arg created_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  --arg opencode_version "$(opencode --version)" \
  --arg planning_session_id "$PLANNING_SESSION_ID" \
  --arg dotfiles_commit "$(git -C "$HOME/projects/dotfiles" rev-parse HEAD)" \
  '{format_version:2,created_at:$created_at,opencode_version:$opencode_version,
    planning_session_id:$planning_session_id,dotfiles_commit:$dotfiles_commit,
    sessions:$sessions[0],exports:$checksums[0]}' \
  > "$OPENCODE_STAGE/manifest.json"

exports_archive="$RUN_DIR/opencode-exports.tar.zst.age"
tar -C "$OPENCODE_STAGE" -cpf - manifest.json exports |
  zstd --threads=0 --quiet --stdout |
  age --recipient "$AGE_RECIPIENT" --output "$exports_archive.partial"
mv "$exports_archive.partial" "$exports_archive"
```

Create a consistent raw emergency snapshot. Authentication remains encrypted
and is never restored by default:

```zsh
sqlite3 "$OPENCODE_DB" ".backup '$OPENCODE_STAGE/raw/opencode.db'"
test "$(sqlite3 "$OPENCODE_STAGE/raw/opencode.db" 'PRAGMA integrity_check;')" = ok

for source in storage snapshot tool-output auth.json; do
  path="$HOME/.local/share/opencode/$source"
  [[ ! -e "$path" ]] || rsync -a "$path" "$OPENCODE_STAGE/raw/"
done

raw_archive="$RUN_DIR/opencode-raw.tar.zst.age"
tar -C "$OPENCODE_STAGE" -cpf - raw |
  zstd --threads=0 --quiet --stdout |
  age --recipient "$AGE_RECIPIENT" --output "$raw_archive.partial"
mv "$raw_archive.partial" "$raw_archive"
```

Register and verify both archives with the common pipeline:

```zsh
"$REINSTALL" backup register opencode-exports "$exports_archive"
"$REINSTALL" backup register opencode-raw "$raw_archive"
"$REINSTALL" status
"$REINSTALL" continue
```

Continue through `agent_state`, upload, remote verification, representative
restore, sync-only recovery, finalization, and erase approval in order. Direct
subcommands do not advance the state machine.

Do not remove plaintext staging or erase the Mac until finalization and
representative restore tests succeed. After explicit approval, erase manually
through System Settings.

## Part II: Restore on the Fresh Mac

## 1. Reset and Setup Assistant

1. Use System Settings > General > Transfer or Reset > Erase All Content and
   Settings.
2. Create the new account with short name `quangdn`.
3. Do not use Migration Assistant.
4. Sign in to the Apple Account.
5. Enable FileVault and store its recovery key in Bitwarden.
6. Install all macOS updates and restart as required.

The resulting home must be `/Users/quangdn`. If it is not, stop before
restoring data because session path migration assumes that exact path.

## 2. Install Command Line Tools and Homebrew

Install Apple's Command Line Tools:

```sh
xcode-select --install
```

Wait for the installer to finish, then install Homebrew from its official
installer:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Activate Apple Silicon Homebrew in the current shell:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version
```

## 3. Recover the Dotfiles Repository

Install only the tools needed to authenticate, clone, and retrieve the compact
resume state:

```sh
brew install git gh jq rclone
gh auth login --web --git-protocol ssh
mkdir -p "$HOME/projects"
gh repo clone quangdn42/dotfiles "$HOME/projects/dotfiles"
```

Set a variable used by the remaining commands:

```sh
export DOTFILES="$HOME/projects/dotfiles"
test -f "$DOTFILES/reinstall/macos/README.md"
git -C "$DOTFILES" status --short --branch
```

Confirm the checked-out commit matches the final commit recorded in the backup
manifest. Do not proceed with an old runbook.

## Automated Post-Erase Sequence

Run the tracked script directly before Stow exists. `resume` downloads only the
small plaintext resume/manifest/checksum files, verifies their digests, and
refuses a clone at the wrong commit:

```sh
REINSTALL="$DOTFILES/reinstall/macos/bin/reinstall"
"$REINSTALL" resume 'gdrive:mac-reinstall/<run-id>' '<independently-stored-manifest-sha256>'
"$REINSTALL" status
"$REINSTALL" continue
```

Continue one stage at a time. The state machine performs:

1. Post-erase tool and repository preflight.
2. Full Brewfile installation.
3. App Store sign-in gate and `Brewfile.mas` installation.
4. Stow simulation and no-folding deployment; conflicts stop the run and Fisher
   cannot write generated files into the repository.
5. Fish login-shell and Fisher synchronization with a repository-diff guard.
6. mise Go/tool installation, uv Python installation, and both Neovim
   synchronizations.
7. Curated defaults application.
8. Encrypted archive download and checksum validation.
9. Archive path/link/type inspection into reports, never terminal-sized lists.
10. Extraction into private category staging directories.
11. `rsync` conflict reports and the `restore_apply` human gate.
12. No-overwrite application for categories whose policy permits automatic
    merging. Credentials, browsers, application state, and agents remain staged
    or application-specific.
13. Account, browser, and Raycast sync gates.
14. Kanata privileged installation followed by privacy-permission acceptance.
15. Agent-session, FileVault, bootstrap-verification, and final-acceptance gates.

Retrieve the age identity from Bitwarden before archive inspection. Save it at
`~/.config/age/reinstall-key.txt` with mode `600`; never pass the private value
on a command line.

The remaining numbered sections are the manual fallback and application-specific
trail. Do not repeat a completed automated stage merely because it appears
below.

## 4. Reinstall Declared Software Manually

Install Homebrew formulae, fonts, and casks:

```sh
brew bundle --file="$DOTFILES/Brewfile"
```

Open the App Store and sign in manually. Then install App Store-only fallback
applications:

```sh
brew bundle --file="$DOTFILES/Brewfile.mas"
```

TinkerTool is intentionally not automated. If it is still wanted, download it
from the verified vendor website after the rebuild.

Check the base declaration:

```sh
brew bundle check --file="$DOTFILES/Brewfile"
```

Do not run `brew bundle cleanup` against either manifest.

## 5. Deploy Dotfiles with Stow Manually

Preview the shared and macOS deployment:

```sh
stow --dir="$DOTFILES" --target="$HOME" --simulate --verbose=2 shared macos
```

If Stow reports a conflict, do not delete the conflicting file. Move it to a
temporary recovery directory, inspect it, and rerun the simulation. Never
deploy the `linux` package on macOS.

Apply the deployment:

```sh
stow --dir="$DOTFILES" --target="$HOME" --restow shared macos
```

Verify representative links:

```sh
readlink "$HOME/.gitconfig"
readlink "$HOME/.config/fish/config.fish"
readlink "$HOME/.config/ghostty/config"
readlink "$HOME/.config/zed/settings.json"
```

After signing in to Bitwarden Desktop, use it to verify the `Macbook Air
general` SSH item. Register the independent `rbw` client once, then install the
key from that authoritative vault item:

```sh
rbw register
ssh-key-sync c0071171-1062-4ea1-a5dc-b49a00051e81
rbw lock
```

The refresh opens `pinentry-mac` for the Bitwarden password. It requires
FileVault and preserves any installed key if sync, export, or validation fails.
Do not restore an archived `id_ed25519` over this fresh copy later.

## 6. Configure Fish, Fisher, and Runtimes Manually

Add Fish to the allowed login shells and select it:

```sh
FISH_PATH="/opt/homebrew/bin/fish"
grep -qxF "$FISH_PATH" /etc/shells || printf '%s\n' "$FISH_PATH" | sudo tee -a /etc/shells
chsh -s "$FISH_PATH"
```

Install Fisher and synchronize the tracked plugin list:

```sh
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher update'
```

Install the global Go 1.26 track and shared Go tools declared by mise, then
install the newest Python 3.12 patch through uv. The `--default` option publishes
`python` and `python3` in `~/.local/bin`, which the tracked Fish config places
before system paths:

```sh
eval "$(mise activate zsh)"
mise install
uv python install 3.12 --default
uv run --no-project --managed-python --python 3.12 python --version
mise exec -- go version
mise exec -- gopls version
mise exec -- gofumpt -version
```

Node.js, Rust, and Zig are not global development-runtime defaults. Homebrew
may install Node.js as a dependency of editor tooling. From a restored project
that contains `mise.toml`, review the file and run `mise install` in that
project only.

Keep this zsh terminal open for the runbook. Fish becomes the login shell in a
later terminal session; reopening now would lose temporary shell variables and
make the following zsh commands invalid.

## 7. Restore Downloaded Archives Manually

Installations from `Brewfile` provide age, rclone, and zstd. Create a local
recovery area:

```sh
export RECOVERY_ROOT="$HOME/reinstall-recovery"
export AGE_IDENTITY="$HOME/.config/age/reinstall-key.txt"
export BACKUP_REMOTE="gdrive:mac-reinstall/<run-id>"
export RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
export RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
mkdir -p "$RECOVERY_ROOT/downloads" "$HOME/.config/age"
chmod 700 "$HOME/.config/age"
```

Retrieve the age private identity from Bitwarden. Save it to
`$AGE_IDENTITY` using an editor rather than putting the secret directly in a
shell command, then restrict it:

```sh
chmod 600 "$AGE_IDENTITY"
```

Configure the same Google Drive remote name used during backup if rclone does
not already have it:

```sh
rclone config
```

List and download the backup run:

```sh
rclone lsf "$BACKUP_REMOTE"
rclone copy "$BACKUP_REMOTE" "$RECOVERY_ROOT/downloads" --progress
```

Verify the downloaded files against the final manifest:

```sh
cd "$RECOVERY_ROOT/downloads"
shasum -a 256 -c SHA256SUMS
```

Do not extract an archive whose checksum fails.

Archive filenames are stable inside the timestamped run directory. Use the
exact filename recorded in `SHA256SUMS` and the final manifest.

Define helpers for structural validation and private staged extraction. The
validator rejects absolute paths, `..`, escaping links, duplicate members, and
special files before extraction:

```sh
set -o pipefail
HELPER="$DOTFILES/reinstall/macos/lib/reinstall_helper.py"

inspect_archive() {
  archive="$1"
  report="$2"
  archive_sha="$(shasum -a 256 "$archive" | cut -d ' ' -f 1)"
  age --decrypt --identity "$AGE_IDENTITY" "$archive" |
    zstd --decompress --stdout |
    python3 "$HELPER" validate-tar \
      --archive-sha256 "$archive_sha" \
      --output "$report"
}

stage_archive() {
  archive="$1"
  destination="$2"
  test ! -e "$destination"
  mkdir -p "$destination"
  chmod 700 "$destination"
  age --decrypt --identity "$AGE_IDENTITY" "$archive" |
    zstd --decompress --stdout |
    tar -xpf - -C "$destination"
}
```

Always run `inspect_archive` before `stage_archive`. Never extract an archive
directly into the home directory.

## 8. Restore Selected User Data

The personal, downloads, workspaces, and projects archives contain paths
relative to the old home. Validate and extract them into separate staging
directories:

```sh
cd "$RECOVERY_ROOT/downloads"
for id in personal downloads workspaces projects; do
  inspect_archive "$id.tar.zst.age" "$RECOVERY_ROOT/$id.listing.json"
  stage_archive "$id.tar.zst.age" "$RECOVERY_ROOT/staging/$id"
done
```

Review no-overwrite conflict plans before copying anything. The projects
fallback excludes the old dotfiles checkout even when handling a legacy archive
that predates the tracked archive definition:

```sh
for id in personal downloads workspaces; do
  rsync -ain "$RECOVERY_ROOT/staging/$id/" "$HOME/" \
    > "$RECOVERY_ROOT/$id.rsync.txt"
done
rsync -ain --exclude='projects/dotfiles/**' \
  "$RECOVERY_ROOT/staging/projects/" "$HOME/" \
  > "$RECOVERY_ROOT/projects.rsync.txt"
```

After human review, copy only missing files. Never overwrite the fresh dotfiles
clone or other newly created files:

```sh
for id in personal downloads workspaces; do
  rsync -a --ignore-existing "$RECOVERY_ROOT/staging/$id/" "$HOME/"
done
rsync -a --ignore-existing --exclude='projects/dotfiles/**' \
  "$RECOVERY_ROOT/staging/projects/" "$HOME/"
```

Compare restored counts and sizes with the final manifest.

## 9. Restore Credentials Carefully

Extract credentials to a staging directory, not directly into the new home:

```sh
inspect_archive credentials.tar.zst.age "$RECOVERY_ROOT/credentials.listing.json"
stage_archive credentials.tar.zst.age "$RECOVERY_ROOT/credentials"
```

Inspect the staged paths. The current `id_ed25519` comes from Bitwarden via
`ssh-key-sync`; do not overwrite it from this archive. Preview the other SSH
files only if they are still required:

```sh
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
rsync -ainAX "$RECOVERY_ROOT/credentials/.ssh/" "$HOME/.ssh/" \
  > "$RECOVERY_ROOT/credentials-ssh.rsync.txt"
```

Review the report and preserve the fresh Bitwarden-sourced key and current
configuration. Then copy only missing files while retaining modes, ACLs, and
extended attributes:

```sh
rsync -aAX --ignore-existing \
  --exclude='id_ed25519' --exclude='id_ed25519.pub' \
  "$RECOVERY_ROOT/credentials/.ssh/" "$HOME/.ssh/"
```

Reauthenticate GitHub, Google Drive, Bitwarden, Tailscale, coding agents, and
other services. Do not restore old application tokens merely because they are
present in the emergency archive.

## 10. Restore Browser History and Settings

1. Install and launch Safari, Chrome, Firefox, and Arc normally.
2. Sign in and allow browser sync to finish.
3. Confirm bookmarks, extensions, settings, and history.
4. Extract each available browser archive under `$RECOVERY_ROOT/browsers`,
   never over a running browser profile. No Safari archive exists for this run.
5. Use the raw archive only to recover data that sync did not restore.

Edge is not reinstalled automatically, but its archived profile remains
available for manual recovery. Chromium cookies and passwords tied to the old
Keychain may not work on the new account.

## 11. Restore OpenCode Sessions

The sanitized OpenCode configuration is already deployed by Stow. Sign in
again:

```sh
opencode auth login
```

Extract the portable session exports to a recovery directory:

```sh
inspect_archive opencode-exports.tar.zst.age "$RECOVERY_ROOT/opencode.listing.json"
stage_archive opencode-exports.tar.zst.age "$RECOVERY_ROOT/opencode"
```

Use the encrypted session manifest to map each export to its restored project
directory. Import from that directory so OpenCode binds the session to
`/Users/quangdn`:

```sh
cd "$HOME/projects/<project>"
opencode import "$RECOVERY_ROOT/opencode/exports/<session>.json"
```

Repeat for every exported session. Compare the imported count with the final
manifest and open representative sessions. Keep `opencode-raw.tar.zst.age`
untouched as an emergency fallback; do not restore its old `auth.json` by
default. See `opencode.md` for raw database recovery details.

## 12. Restore Native Zed Agent Threads

Extract the Zed archive into staging:

```sh
inspect_archive zed-agent.tar.zst.age "$RECOVERY_ROOT/zed.listing.json"
stage_archive zed-agent.tar.zst.age "$RECOVERY_ROOT/zed"
```

The archive has a `zed-agent` top-level directory. Work only on copies of its
native thread and stable databases. Migrate plain folder-path metadata in the
native rows and in the native-agent sidebar rows:

```sh
export ZED_STAGE="$RECOVERY_ROOT/zed/zed-agent"
export SOURCE_HOME="$(jq -r '.source_home' "$RUN_DIR/downloads/manifest.json")"
export TARGET_HOME="$(jq -r '.target_home' "$RUN_DIR/downloads/manifest.json")"
cp "$ZED_STAGE/threads.db" "$RECOVERY_ROOT/zed/threads.migrated.db"
cp "$ZED_STAGE/zed-stable.db" "$RECOVERY_ROOT/zed/zed-stable.migrated.db"

sqlite3 "$RECOVERY_ROOT/zed/threads.migrated.db" <<SQL
UPDATE threads
SET folder_paths = replace(folder_paths, '$SOURCE_HOME', '$TARGET_HOME')
WHERE folder_paths IS NOT NULL;
PRAGMA integrity_check;
SQL

sqlite3 "$RECOVERY_ROOT/zed/zed-stable.migrated.db" <<SQL
BEGIN IMMEDIATE;
UPDATE sidebar_threads
SET folder_paths = replace(folder_paths, '$SOURCE_HOME', '$TARGET_HOME'),
    main_worktree_paths = replace(main_worktree_paths, '$SOURCE_HOME', '$TARGET_HOME')
WHERE agent_id IS NULL;
COMMIT;
PRAGMA integrity_check;
SQL
```

Define a helper that installs the native thread content and selectively merges
only native Zed Agent sidebar rows into an initialized profile. Do not replace
the complete stable database:

```sh
install_zed_threads() {
  threads_target="$1"
  stable_target="$2"
  mkdir -p "$(dirname "$threads_target")"
  cp "$RECOVERY_ROOT/zed/threads.migrated.db" "$threads_target"

  sqlite3 "$stable_target" <<SQL
ATTACH '$RECOVERY_ROOT/zed/zed-stable.migrated.db' AS restored;
BEGIN IMMEDIATE;
DELETE FROM sidebar_threads WHERE agent_id IS NULL;
INSERT INTO sidebar_threads (
  thread_id, session_id, agent_id, title, updated_at, created_at,
  folder_paths, folder_paths_order, archived, main_worktree_paths,
  main_worktree_paths_order, remote_connection, interacted_at, title_override
)
SELECT
  thread_id, session_id, agent_id, title, updated_at, created_at,
  folder_paths, folder_paths_order, archived, main_worktree_paths,
  main_worktree_paths_order, remote_connection, interacted_at, title_override
FROM restored.sidebar_threads
WHERE agent_id IS NULL;
COMMIT;
PRAGMA integrity_check;
SQL
}
```

Initialize an isolated profile with the app binary, then quit it. Install the
migrated copies and launch it again for validation:

```sh
"/Applications/Zed.app/Contents/MacOS/zed" \
  --user-data-dir "$RECOVERY_ROOT/zed-test"

install_zed_threads \
  "$RECOVERY_ROOT/zed-test/threads/threads.db" \
  "$RECOVERY_ROOT/zed-test/db/0-stable/db.sqlite"

"/Applications/Zed.app/Contents/MacOS/zed" \
  --user-data-dir "$RECOVERY_ROOT/zed-test"
```

Confirm all native threads appear, then quit the isolated instance. Quit normal
Zed, back up its fresh thread and stable databases, and install the same
selective restore:

```sh
export ZED_HOME="$HOME/Library/Application Support/Zed"
export ZED_FRESH_BACKUP="$RECOVERY_ROOT/zed-normal-before-restore"
mkdir -p "$ZED_FRESH_BACKUP"

sqlite3 "$ZED_HOME/threads/threads.db" \
  ".backup '$ZED_FRESH_BACKUP/threads.db'"
sqlite3 "$ZED_HOME/db/0-stable/db.sqlite" \
  ".backup '$ZED_FRESH_BACKUP/zed-stable.db'"

install_zed_threads \
  "$ZED_HOME/threads/threads.db" \
  "$ZED_HOME/db/0-stable/db.sqlite"
```

The compressed native thread payloads can retain old sandbox paths; do not
broaden those grants to the new home. The selective sidebar merge is required
because Zed may not recreate all visible sidebar rows from `threads.db` alone.

## 13. Restore Codex and Zed External-Agent Threads

Extract the Codex archive into staging:

```sh
inspect_archive codex-agent.tar.zst.age "$RECOVERY_ROOT/codex.listing.json"
stage_archive codex-agent.tar.zst.age "$RECOVERY_ROOT/codex"
```

Preserve any newly created Codex directory, then copy the curated old state
without restoring old authentication:

```sh
export SOURCE_HOME="$(jq -r '.source_home' "$RUN_DIR/downloads/manifest.json")"
export TARGET_HOME="$(jq -r '.target_home' "$RUN_DIR/downloads/manifest.json")"
if test -d "$HOME/.codex"; then
  mv "$HOME/.codex" "$RECOVERY_ROOT/codex-fresh-$(date -u '+%Y%m%dT%H%M%SZ')"
fi
mkdir -p "$HOME/.codex"
chmod 700 "$HOME/.codex"
rsync -aAX --exclude='auth.json' "$RECOVERY_ROOT/codex/codex-agent/.codex/" "$HOME/.codex/"
```

Update the Codex thread index on the restored copy:

```sh
sqlite3 "$HOME/.codex/state_5.sqlite" <<SQL
BEGIN IMMEDIATE;
UPDATE threads
SET cwd = replace(cwd, '$SOURCE_HOME', '$TARGET_HOME')
WHERE cwd LIKE '$SOURCE_HOME/%';
UPDATE threads
SET rollout_path = replace(rollout_path, '$SOURCE_HOME', '$TARGET_HOME')
WHERE rollout_path LIKE '$SOURCE_HOME/%';
COMMIT;
PRAGMA integrity_check;
SQL
```

Migrate exact old-home prefixes inside structured session JSONL values. This
script does not replace paths embedded in arbitrary prose and keeps the
encrypted original unchanged:

```sh
uv run --no-project --managed-python --python 3.12 python - "$HOME/.codex/sessions" "$SOURCE_HOME" "$TARGET_HOME" <<'PY'
import json
import os
import shutil
import sys
from pathlib import Path

OLD = sys.argv[2]
NEW = sys.argv[3]


def migrate(value):
    if isinstance(value, str) and value.startswith(OLD):
        return NEW + value[len(OLD):]
    if isinstance(value, list):
        return [migrate(item) for item in value]
    if isinstance(value, dict):
        return {key: migrate(item) for key, item in value.items()}
    return value


for path in Path(sys.argv[1]).rglob("*.jsonl"):
    temporary = path.with_name(path.name + ".migrating")
    changed = False
    with path.open("r", encoding="utf-8") as source, temporary.open(
        "w", encoding="utf-8"
    ) as destination:
        for line in source:
            if not line.strip():
                destination.write(line)
                continue
            original = json.loads(line)
            updated = migrate(original)
            changed = changed or updated != original
            destination.write(
                json.dumps(updated, ensure_ascii=False, separators=(",", ":")) + "\n"
            )
    if changed:
        shutil.copymode(path, temporary)
        os.replace(temporary, path)
    else:
        temporary.unlink()
PY
```

Search the restored Codex state for remaining old-home references. Review each
match rather than applying a broad replacement; prose and historical command
output may legitimately mention the old path:

```sh
rg --hidden --line-number --fixed-strings "$SOURCE_HOME" "$HOME/.codex" \
  --glob='!auth.json' \
  --glob='!*.sqlite' \
  --glob='!*.sqlite-shm' \
  --glob='!*.sqlite-wal'
```

Preserve the untouched encrypted archive and timestamped fresh-state backup
until Codex and Zed validation succeeds.

After installing the migrated state, sign in and verify Codex sees it:

```sh
codex login
codex resume --all
```

In Zed:

1. Open the ACP Registry and install Codex.
2. Open the Threads Sidebar.
3. Open Thread History.
4. Select **Import Threads**.
5. Select Codex and import.

Zed documents re-importing as safe because already known sessions are skipped.
Compare visible Zed and Codex counts with the final manifest.

## 14. Restore Selected History and Application State

Extract these archives to staging first:

```sh
inspect_archive developer-history.tar.zst.age "$RECOVERY_ROOT/history.listing.json"
stage_archive developer-history.tar.zst.age "$RECOVERY_ROOT/history"
inspect_archive app-state.tar.zst.age "$RECOVERY_ROOT/apps.listing.json"
stage_archive app-state.tar.zst.age "$RECOVERY_ROOT/apps"
inspect_archive raycast-state.tar.zst.age "$RECOVERY_ROOT/raycast.listing.json"
stage_archive raycast-state.tar.zst.age "$RECOVERY_ROOT/raycast"
```

Restore only the reviewed developer-history files listed in `backup.md`: Fish,
database CLI, zoxide, and Lazygit history. Do not restore zsh/bash, REPL,
Vim/Neovim, VS Code, or extra AI histories.

For Raycast, sign in and use Raycast Sync first. Never restore the old exposed
token. Consult the raw encrypted state only for a specific missing clipboard,
note, activity, or extension item.

Restore OBS scenes/profiles, GIMP resources, Steam `userdata`, and
`~/Library/ScreenRecordings` selectively from staging. Redownload Steam games.

## 15. Restore Apple Local-Only Data

Allow Apple account synchronization to finish before restoring local stores.
Verify Messages, Mail, Notes, Voice Memos, contacts, calendars, reminders,
device backups, and iCloud Keychain.

No `apple-local-state.tar.zst.age` was created for this run. Rely on Apple
account synchronization and stop if required local-only data is missing.

For a future run where that archive exists, extract it to staging:

```sh
inspect_archive apple-local-state.tar.zst.age "$RECOVERY_ROOT/apple.listing.json"
stage_archive apple-local-state.tar.zst.age "$RECOVERY_ROOT/apple"
```

Restore only data previously identified as local-only. Do not replace complete
fresh Apple databases with old copies while their applications or sync agents
are running. Raw Keychains and protected databases are emergency sources and
may require service-specific import rather than file replacement.

## 16. Restore Editors and Plugins

Synchronize both Neovim configurations:

```sh
nvim --headless '+Lazy! sync' +qa
NVIM_APPNAME=lazyvim nvim --headless '+Lazy! sync' +qa
bat cache --build
```

Open each Neovim setup and review `:checkhealth` and `:Mason`. Neovim and
LazyVim session, undo, shada, swap, and scratch state were intentionally not
backed up.

Configure VS Code fresh. Its old local History, workspace state, backups, and
chat state were intentionally excluded.

## 17. Reapply Reviewed macOS Settings

Apply the tracked curated defaults, then configure three-finger drag manually:

```sh
"$DOTFILES/macos/.config/macos/defaults.sh"
```

The script owns only these reviewed behaviors:

- Dock auto-hide with no delay or animation, size 56, no recent apps, minimize
  into app icon, and no automatic Spaces reordering
- Finder column view and path bar, with status bar hidden
- Fast key repeat and press-and-hold accents disabled
- Tap-to-click; configure three-finger drag manually in System Settings
- Screenshots saved under `~/Pictures/Screenshots`

Do not replay complete old preference domains. The script intentionally does
not write three/four-finger gesture-domain values because macOS couples them.

## 18. Install Kanata Last

The committed installer generates launchd paths from the active `$HOME` and
verifies both daemons reach steady state. Confirm no active file contains the
old home before running it:

```sh
SOURCE_HOME="$(jq -r '.source_home' "$RUN_DIR/downloads/manifest.json")"
grep -R -F "$SOURCE_HOME" "$DOTFILES/macos/.config/kanata/launchd"
```

If the command prints an active installer or plist path, stop. Otherwise follow
`macos/.config/kanata/launchd/README.md` and complete Driver Extension, Input
Monitoring, and Accessibility approval. Homebrew installs the binary earlier;
"install Kanata last" means enabling its privileged daemons last.

## 19. Complete Manual Permissions and Logins

Review permissions for:

- Kanata: Driver Extension, Input Monitoring, and Accessibility
- FlashSpace, Raycast, Mac Mouse Fix, and Swish: Accessibility
- Shottr and OBS: Screen Recording
- OBS: camera and microphone as needed
- Google Drive: File Provider access
- Safari: Vimari and uBlock Origin Lite extensions

Sign in to communication, media, sync, and licensed applications. WhatsApp and
Zalo local databases were intentionally not backed up; allow their supported
account/cloud recovery to complete.

## 20. Final Verification

Run these checks:

```sh
brew bundle check --file="$DOTFILES/Brewfile"
brew services list
fish -lc 'type -q mise; and mise doctor'
fish -lc 'uv run --no-project --managed-python --python 3.12 python --version'
git -C "$DOTFILES" status --short --branch
fdesetup status
"$DOTFILES/reinstall/macos/bin/reinstall" status
```

Also verify:

- Both Neovim configurations start.
- Ghostty, FlashSpace, and Kanata work.
- Browser history, bookmarks, extensions, and settings are available.
- OpenCode, native Zed, and Codex representative sessions open successfully.
- Restored data matches the final backup manifest.
- No unwanted Homebrew service is running.
- Bootstrap declarations can be reapplied without harmful changes.

Continue through the account, browser, Raycast, privacy-permission, agent-session,
FileVault, and final-acceptance gates. Each gate must be reached in order:

```sh
"$DOTFILES/reinstall/macos/bin/reinstall" continue
```

The final gate requires `RETAIN UNTIL YYYY-MM-DD` with a date at least 90 days
ahead and records it in run evidence. Keep all encrypted archives and untouched
raw agent databases until that date.

## Failure Rule

If any archive, identity, account, path migration, or session restore behaves
unexpectedly, stop and keep the original encrypted archive unchanged. Work on
a new copy and consult the focused documents in this directory. Never solve a
path migration problem by creating a compatibility symlink for an old home.
