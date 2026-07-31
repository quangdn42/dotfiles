# Manual Backup and Restore

**Start here for the reinstall.** This is the sole end-to-end execution guide:
follow it from the current Mac's backup through verification on the rebuilt
Mac. The other files in this directory are references, not competing runbooks.

[`fast-path.md`](fast-path.md) is an optional post-reset branch that restores
the current OpenCode planning session early. It returns to this runbook for the
remaining restore.

Read this complete document before erasing. Do not use Migration Assistant and
do not restore the complete old home or `~/Library` directory.

Pre-reset examples use Fish where shell state is required. Post-reset commands
use the default zsh available during macOS Setup. Commands containing
placeholders such as `<run-id>` must be edited before use.

## Current Backup Run

The active direct backup is intentionally operator-led rather than implemented
as a reusable script.

| Item | Value |
| --- | --- |
| Run ID | `20260731T185734Z-Quangs-MacBook-Air` |
| Local staging | `~/reinstall-staging/20260731T185734Z-Quangs-MacBook-Air` |
| Google Drive | `gdrive:mac-reinstall/20260731T185734Z-Quangs-MacBook-Air` |
| age recipient | `age10h93te23flq6a6uhvh4s5k83r44xdrvxx7zwdd2zja6hx0cyl3xs2vcxxr` |

Completed archives have passed local decryption/listing and a SHA-256 check of
the complete remote stream:

- `credentials.tar.zst.age`
- `developer-history.tar.zst.age`
- `personal.tar.zst.age`
- `downloads.tar.zst.age`
- `workspaces.tar.zst.age`
- `browser-firefox.tar.zst.age`
- `browser-brave.tar.zst.age`
- `browser-edge.tar.zst.age`
- `browser-arc.tar.zst.age`
- `browser-chrome.tar.zst.age`
- `app-state.tar.zst.age`
- `raycast-state.tar.zst.age`
- `zed-agent.tar.zst.age`
- `codex-agent.tar.zst.age`

Safari raw state and Apple local state were explicitly skipped; use supported
cloud synchronization for both. A failed local Safari artifact is not uploaded
and must not enter the final manifest.

`projects/` remains the final agent-run data archive. The current OpenCode
session export and raw-state snapshot happen from a normal terminal only after
this session is finished and closed.

## Part I: Back Up the Current Mac

Follow this sequence without skipping ahead:

1. Complete **Required Recovery Access** and every pre-erase item in
   [`checklist.md`](checklist.md).
2. Create each logical encrypted archive listed below, one at a time.
3. For each archive, create a SHA-256 sidecar, decrypt and list it locally,
   upload it, and hash the complete remote stream before starting the next.
4. Close the owning application before archiving a browser or live database.
5. Finish and push the dotfiles runbook, then archive `projects/` last.
6. Finish and close OpenCode, then create the final portable exports and raw
   state backup from a normal terminal.
7. Generate the final manifest, download and extract representative archives,
   and complete the **Erase Gate** in `checklist.md`.
8. Obtain explicit approval before using Erase All Content and Settings.
9. After reset, optionally use `fast-path.md`, then continue at **1. Reset and
   Setup Assistant** below.

The required archive order is:

| Order | Archive | State |
| ---: | --- | --- |
| 1 | Credentials and selected developer history | Complete |
| 2 | Personal roots, Downloads, and workspaces | Complete |
| 3 | Chrome, Edge, Firefox, Arc, and Brave browser archives | Complete; Safari uses sync only |
| 4 | Curated application state and Raycast emergency state | Complete |
| 5 | Selected local-only Apple state | Skipped; cloud verification required |
| 6 | Native Zed and Codex state | Complete |
| 7 | Final dotfiles commit and complete `projects/` archive | Pending; projects last |
| 8 | OpenCode portable exports and raw emergency state | Final terminal-only step |

Use [`backup.md`](backup.md) only when this sequence calls for exact retained
paths, exclusions, archive contents, or verification rationale. Use
[`opencode.md`](opencode.md) and [`zed.md`](zed.md) only for their respective
agent-state steps.

## Required Recovery Access

Before erasing, confirm that all of these work without relying on this Mac:

- Apple Account and App Store login
- Bitwarden login and two-factor recovery
- Google Drive login and rclone authorization
- GitHub login and access to `quangdn42/dotfiles`
- The age private identity stored in Bitwarden
- The final backup run ID and checksum manifest

The GitHub repository and Google Drive backup are both required. Keep a copy of
the final archive manifest in Google Drive outside the encrypted archives.

## Backup Shell State

Set these variables in Fish before manually creating or verifying an archive:

```fish
set -gx RUN_ID "20260731T185734Z-Quangs-MacBook-Air"
set -gx RUN_DIR "$HOME/reinstall-staging/$RUN_ID"
set -gx BACKUP_REMOTE "gdrive:mac-reinstall/$RUN_ID"
set -gx AGE_IDENTITY "$HOME/.config/age/reinstall-key.txt"
set -gx AGE_RECIPIENT "age10h93te23flq6a6uhvh4s5k83r44xdrvxx7zwdd2zja6hx0cyl3xs2vcxxr"
```

Verify the shell points at the expected run before proceeding:

```fish
test -d "$RUN_DIR"
test (age-keygen -y "$AGE_IDENTITY") = "$AGE_RECIPIENT"
rclone lsf "$BACKUP_REMOTE"
```

## Per-Archive Procedure

Every archive follows the same gates even though its source paths and cache
exclusions differ. Determine those paths from the archive table above and the
focused `backup.md`, `opencode.md`, or `zed.md` reference.

1. Confirm the owning applications are closed.
2. Record source paths, allocated KiB, and file count in
   `<category>.metadata.json`.
3. Create only the encrypted output; do not stage a plaintext tarball:

   ```fish
   tar --acls --xattrs <exclusions> -C "$HOME" -cpf - <relative-source-paths> \
     | zstd --threads=0 --quiet --stdout \
     | age --recipient "$AGE_RECIPIENT" --output "$RUN_DIR/<archive>.tar.zst.age"
   ```

4. Create the SHA-256 sidecar:

   ```fish
   cd "$RUN_DIR"
   shasum -a 256 "<archive>.tar.zst.age" > "<archive>.tar.zst.age.sha256"
   ```

5. Decrypt and list the complete local archive. Review the paths before any
   later extraction:

   ```fish
   age --decrypt --identity "$AGE_IDENTITY" "<archive>.tar.zst.age" \
     | zstd --decompress --quiet --stdout \
     | tar -tf -
   ```

6. Upload the archive, checksum, and metadata:

   ```fish
   rclone copyto "<archive>.tar.zst.age" \
     "$BACKUP_REMOTE/<archive>.tar.zst.age"
   rclone copyto "<archive>.tar.zst.age.sha256" \
     "$BACKUP_REMOTE/<archive>.tar.zst.age.sha256"
   rclone copyto "<category>.metadata.json" \
     "$BACKUP_REMOTE/<category>.metadata.json"
   ```

7. Hash the complete remote stream and compare it with the local sidecar:

   ```fish
   set local_sha (/usr/bin/cut -d ' ' -f 1 \
     "<archive>.tar.zst.age.sha256")
   set remote_sha (rclone cat "$BACKUP_REMOTE/<archive>.tar.zst.age" \
     | shasum -a 256 \
     | /usr/bin/cut -d ' ' -f 1)
   test "$local_sha" = "$remote_sha"
   ```

Do not mark an archive complete if any pipeline, upload, listing, or checksum
fails. Do not overwrite a remote archive solely because verification was
interrupted; verify the existing object first.

## Final Pre-Erase Steps

After all category archives are complete:

1. Finish and push this repository.
2. Archive `projects/` last and verify it like every other archive.
3. Finish and close this OpenCode session.
4. From a normal terminal, create and verify the final OpenCode portable export
   and raw-state archives.
5. Build `SHA256SUMS` and the final manifest from the verified metadata files.
6. Upload both files and test representative full extractions into temporary
   directories.
7. Complete every item under **Erase Gate** in `checklist.md`.
8. Stop for explicit approval.

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

Install only the tools needed to authenticate and clone the repository:

```sh
brew install git gh
gh auth login --web --git-protocol ssh
mkdir -p "$HOME/projects"
gh repo clone quangdn42/dotfiles "$HOME/projects/dotfiles"
```

Set a variable used by the remaining commands:

```sh
export DOTFILES="$HOME/projects/dotfiles"
test -f "$DOTFILES/REINSTALL.md"
git -C "$DOTFILES" status --short --branch
```

Confirm the checked-out commit matches the final commit recorded in the backup
manifest. Do not proceed with an old runbook.

## 4. Reinstall Declared Software

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

## 5. Deploy Dotfiles with Stow

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

## 6. Configure Fish, Fisher, and mise

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

Install the global Python 3.12 and Go 1.26 tracks and shared Go tools declared
by mise:

```sh
eval "$(mise activate zsh)"
mise install
mise exec -- python --version
mise exec -- go version
mise exec -- gopls version
mise exec -- gofumpt -version
```

Node.js, Rust, and Zig are not global development-runtime defaults. Homebrew
may install Node.js as a dependency of editor tooling. From a restored project
that contains `mise.toml`, review the file and run `mise install` in that
project only.

Close and reopen the terminal after changing the login shell.

## 7. Restore Downloaded Archives

Installations from `Brewfile` provide age, rclone, and zstd. Create a local
recovery area:

```sh
export RECOVERY_ROOT="$HOME/reinstall-recovery"
export AGE_IDENTITY="$HOME/.config/age/reinstall-key.txt"
export BACKUP_REMOTE="gdrive:mac-reinstall/<run-id>"
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

The commands below use logical filenames such as `personal.tar.zst.age` for
readability. Final archives may include a UTC timestamp and machine identifier.
Substitute the exact filename recorded in `SHA256SUMS` and the final manifest.

Define helpers for listing and extracting an encrypted archive:

```sh
set -o pipefail

list_archive() {
  age --decrypt --identity "$AGE_IDENTITY" "$1" |
    zstd --decompress --stdout |
    tar -tf -
}

extract_archive() {
  archive="$1"
  destination="$2"
  mkdir -p "$destination"
  age --decrypt --identity "$AGE_IDENTITY" "$archive" |
    zstd --decompress --stdout |
    tar -xpf - -C "$destination"
}
```

Always run `list_archive <archive>` before extraction and confirm the paths are
relative, expected, and do not contain `..` traversal components.

## 8. Restore Selected User Data

The personal, downloads, and workspaces archives are designed to contain paths
relative to the old home and can be extracted into the new home after listing
them:

```sh
cd "$RECOVERY_ROOT/downloads"
list_archive personal.tar.zst.age
extract_archive personal.tar.zst.age "$HOME"

list_archive downloads.tar.zst.age
extract_archive downloads.tar.zst.age "$HOME"

list_archive workspaces.tar.zst.age
extract_archive workspaces.tar.zst.age "$HOME"
```

The projects archive contains the old dotfiles checkout. Preserve the fresh
GitHub clone by excluding that path during extraction:

```sh
list_archive projects.tar.zst.age
age --decrypt --identity "$AGE_IDENTITY" projects.tar.zst.age |
  zstd --decompress --stdout |
  tar -xpf - -C "$HOME" --exclude='projects/dotfiles'
```

Compare the restored file counts and sizes with the final backup manifest.

## 9. Restore Credentials Carefully

Extract credentials to a staging directory, not directly into the new home:

```sh
mkdir -p "$RECOVERY_ROOT/credentials"
extract_archive credentials.tar.zst.age "$RECOVERY_ROOT/credentials"
```

Inspect the staged paths. Restore SSH only if the keys are still required:

```sh
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
cp -a "$RECOVERY_ROOT/credentials/.ssh/." "$HOME/.ssh/"
find "$HOME/.ssh" -type f -exec chmod 600 {} \;
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
mkdir -p "$RECOVERY_ROOT/opencode"
extract_archive opencode-exports.tar.zst.age "$RECOVERY_ROOT/opencode"
```

Use the encrypted session manifest to map each export to its restored project
directory. Import from that directory so OpenCode binds the session to
`/Users/quangdn`:

```sh
cd "$HOME/projects/<project>"
opencode import "$RECOVERY_ROOT/opencode/<session>.json"
```

Repeat for every exported session. Compare the imported count with the final
manifest and open representative sessions. Keep `opencode-raw.tar.zst.age`
untouched as an emergency fallback; do not restore its old `auth.json` by
default. See `opencode.md` for raw database recovery details.

## 12. Restore Native Zed Agent Threads

Extract the Zed archive into staging:

```sh
mkdir -p "$RECOVERY_ROOT/zed"
extract_archive zed-agent.tar.zst.age "$RECOVERY_ROOT/zed"
```

Work only on a copy of the native thread database. Update its plain folder-path
metadata for the new home and check integrity:

```sh
cp "$RECOVERY_ROOT/zed/threads.db" "$RECOVERY_ROOT/zed/threads.migrated.db"
sqlite3 "$RECOVERY_ROOT/zed/threads.migrated.db" \
  "UPDATE threads SET folder_paths = replace(folder_paths, '/Users/quang-dang', '/Users/quangdn') WHERE folder_paths IS NOT NULL; PRAGMA integrity_check;"
```

Test the copy in an isolated Zed profile:

```sh
mkdir -p "$RECOVERY_ROOT/zed-test/threads"
cp "$RECOVERY_ROOT/zed/threads.migrated.db" "$RECOVERY_ROOT/zed-test/threads/threads.db"
zed --user-data-dir "$RECOVERY_ROOT/zed-test"
```

Confirm the native threads appear, then quit the test Zed instance. Before
launching the normal Zed profile, install the migrated copy:

```sh
mkdir -p "$HOME/Library/Application Support/Zed/threads"
cp "$RECOVERY_ROOT/zed/threads.migrated.db" \
  "$HOME/Library/Application Support/Zed/threads/threads.db"
```

Do not restore the complete old stable Zed database. Zed should rebuild fresh
sidebar metadata from the native thread store. The old compressed thread data
can retain old sandbox paths; do not broaden those grants to the new home.

## 13. Restore Codex and Zed External-Agent Threads

Extract the Codex archive into staging:

```sh
mkdir -p "$RECOVERY_ROOT/codex"
extract_archive codex-agent.tar.zst.age "$RECOVERY_ROOT/codex"
```

Preserve any newly created Codex directory, then copy the curated old state
without restoring old authentication:

```sh
if test -d "$HOME/.codex"; then
  mv "$HOME/.codex" "$HOME/.codex.fresh"
fi
mkdir -p "$HOME/.codex"
chmod 700 "$HOME/.codex"
rsync -a --exclude='auth.json' "$RECOVERY_ROOT/codex/.codex/" "$HOME/.codex/"
```

Update the Codex thread index on the restored copy:

```sh
sqlite3 "$HOME/.codex/state_5.sqlite" <<'SQL'
BEGIN IMMEDIATE;
UPDATE threads
SET cwd = replace(cwd, '/Users/quang-dang', '/Users/quangdn')
WHERE cwd LIKE '/Users/quang-dang/%';
UPDATE threads
SET rollout_path = replace(rollout_path, '/Users/quang-dang', '/Users/quangdn')
WHERE rollout_path LIKE '/Users/quang-dang/%';
COMMIT;
PRAGMA integrity_check;
SQL
```

Migrate exact old-home prefixes inside structured session JSONL values. This
script does not replace paths embedded in arbitrary prose and keeps the
encrypted original unchanged:

```sh
mise exec -- python - "$HOME/.codex/sessions" <<'PY'
import json
import os
import shutil
import sys
from pathlib import Path

OLD = "/Users/quang-dang"
NEW = "/Users/quangdn"


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
rg --hidden --line-number --fixed-strings "/Users/quang-dang" "$HOME/.codex" \
  --glob='!auth.json' \
  --glob='!*.sqlite' \
  --glob='!*.sqlite-shm' \
  --glob='!*.sqlite-wal'
```

Preserve the untouched encrypted archive and `$HOME/.codex.fresh` until Codex
and Zed validation succeeds.

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
mkdir -p "$RECOVERY_ROOT/history" "$RECOVERY_ROOT/apps"
extract_archive developer-history.tar.zst.age "$RECOVERY_ROOT/history"
extract_archive app-state.tar.zst.age "$RECOVERY_ROOT/apps"
extract_archive raycast-state.tar.zst.age "$RECOVERY_ROOT/apps/raycast"
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
mkdir -p "$RECOVERY_ROOT/apple"
extract_archive apple-local-state.tar.zst.age "$RECOVERY_ROOT/apple"
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

Use System Settings to restore the reviewed behavior:

- Dock auto-hide, size 56, no recent apps, minimize into app icon, and no
  automatic Spaces reordering
- Finder column view and path bar, with status bar hidden
- Fast key repeat and press-and-hold accents disabled
- Tap-to-click and three-finger drag
- Screenshots saved under `~/Pictures/Screenshots`

Create the screenshot directory if needed:

```sh
mkdir -p "$HOME/Pictures/Screenshots"
```

The future defaults script may automate these settings. Do not replay complete
old preference domains.

## 18. Install Kanata Last

The committed Kanata installer must be updated to generate paths from the
active `$HOME` before it is run on the rebuilt Mac. Confirm no file still
contains `/Users/quang-dang`:

```sh
grep -R "/Users/quang-dang" "$DOTFILES/macos/.config/kanata/launchd"
```

If the command prints an active installer or plist path, stop and fix the
installer first. Once path-independent, follow
`macos/.config/kanata/launchd/README.md` and complete the Driver Extension and
Input Monitoring approvals.

## 19. Complete Manual Permissions and Logins

Review permissions for:

- Kanata: Driver Extension and Input Monitoring
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
fish -lc 'mise exec -- python --version'
git -C "$DOTFILES" status --short --branch
fdesetup status
```

Also verify:

- Both Neovim configurations start.
- Ghostty, FlashSpace, and Kanata work.
- Browser history, bookmarks, extensions, and settings are available.
- OpenCode, native Zed, and Codex representative sessions open successfully.
- Restored data matches the final backup manifest.
- No unwanted Homebrew service is running.
- Bootstrap declarations can be reapplied without harmful changes.

Keep all encrypted archives and the untouched raw agent databases for at least
90 days after this verification succeeds.

## Failure Rule

If any archive, identity, account, path migration, or session restore behaves
unexpectedly, stop and keep the original encrypted archive unchanged. Work on
a new copy and consult the focused documents in this directory. Never solve a
path migration problem by creating a `/Users/quang-dang` compatibility symlink.
