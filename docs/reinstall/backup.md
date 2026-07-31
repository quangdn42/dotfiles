# Backup and Verification

This is a focused reference. Start and track execution in
[`manual.md`](manual.md); open this file only when that runbook calls for
archive contents, exclusions, or verification rationale.

The internal disk is the erase target and cannot also be the backup. Selected
data is staged into logical compressed archives, encrypted with age, uploaded
to Google Drive with rclone, and verified before reset.

Google Drive is currently the only backup provider. No erase is allowed unless
remote validation and a real download/decryption test succeed.

## Disk Space

At planning time the internal disk had about 8 GB free. Free at least 35-40 GB
before archive creation; about 50 GB is preferred.

Additional space allows one archive to be staged, checksummed, uploaded,
verified, and removed before creating the next. It does not justify one giant
archive. Several logical archives reduce retry cost and isolate corruption.

Do not stage archives inside the Google Drive File Provider mount. Its reported
free space is local disk space, not Google account quota, and it may maintain a
local cache. Use a local staging directory and upload completed files with
rclone.

### Encryption Overhead

Compress before encrypting. The intended pipeline writes only the final
encrypted archive:

```sh
tar ... | zstd ... | age ... > archive.tar.zst.age
```

age is streaming encryption. Its payload overhead is approximately 16 bytes
per 64 KiB chunk, or about 0.024%, plus a small recipient header. This is about
2.5 MB for a 10 GB archive or 10 MB for a 40 GB archive.

Encryption adds CPU work, but on this Mac it should normally be faster than the
Google Drive upload and comparable to or faster than compression. The backup
script will benchmark the actual pipeline before creating final archives.
Skipping age would save little time or disk space while exposing browser,
OpenCode, project, and credential data to the cloud account and its
administrators. Encryption therefore remains required.

### Observed Space Candidates

These sizes were observed on 2026-07-31 and will change. They are listed to
avoid deleting retained data merely to make room for backup staging.

| Candidate | Observed size | Handling |
| --- | ---: | --- |
| Steam installed games under `steamapps` | 17 GB | Uninstall games through Steam after confirming Steam Cloud; preserve `userdata` |
| `~/.orbstack` | 8.1 GB | Remove through OrbStack because local infrastructure was excluded |
| Microsoft Office application bundles | 6.3 GB | Remove the applications; Office was excluded from reinstall |
| `~/.npm` | 3.6 GB | Remove package-manager cache after confirming it contains no intentional local package source |
| `~/.cache` | 2.0 GB | Regenerable, but inspect before deleting the directory broadly |
| `~/.rustup` | 1.2 GB | Remove installed toolchains because Rust will be project-scoped through mise |
| Microsoft Edge application bundle | 1.1 GB | Remove only the app bundle; retain its browser profile for backup |
| `~/.nvm` | 1.0 GB | Remove installed Node versions because Node will be project-scoped through mise |
| Homebrew download cache | 1.0 GB | Clear with Homebrew's supported cleanup command |
| `~/.minikube` | 749 MB | Delete clusters through Minikube because local infrastructure was excluded |
| Other excluded application bundles | About 830 MB | DBeaver, Antigravity, WezTerm, AeroSpace, Amethyst, and Hammerspoon |

The candidates total more than 40 GB. Prefer application-supported uninstall
or cleanup operations over deleting opaque support directories. Do not remove
browser profiles, `~/.local`, Steam `userdata`, or selected user roots while
freeing space.

### Manual Cleanup Commands

Run one block at a time and check free space after each block. These commands
are destructive and do not create a backup.

Quit OrbStack, then remove its data using the locations documented by OrbStack:

```sh
rm -rf "$HOME/.orbstack"
rm -rf "$HOME/Library/Group Containers/HUAQ24HBR6.dev.orbstack"
```

Remove the excluded Microsoft Office application bundles:

```sh
sudo rm -rf "/Applications/Microsoft Excel.app"
sudo rm -rf "/Applications/Microsoft PowerPoint.app"
sudo rm -rf "/Applications/Microsoft Word.app"
```

Remove npm's package cache, temporary npx installs, logs, and prebuild cache.
This does not remove the separate `~/.npmrc` configuration file:

```sh
rm -rf "$HOME/.npm/_cacache"
rm -rf "$HOME/.npm/_npx"
rm -rf "$HOME/.npm/_logs"
rm -rf "$HOME/.npm/_prebuilds"
```

The top-level `~/.cache` inventory contains only regenerable caches for the
currently reviewed applications, including OpenCode's cache but not its session
state under `~/.local/share/opencode`:

```sh
rm -rf "$HOME/.cache"
```

Remove rustup-managed toolchains and proxies. This also removes Rust tooling
under `~/.cargo/bin`, including the installed `rustlings` binary:

```sh
rustup self uninstall -y
```

Remove only the Edge application. Its profile under
`~/Library/Application Support/Microsoft Edge` remains intact for backup:

```sh
sudo rm -rf "/Applications/Microsoft Edge.app"
```

Remove NVM and its managed Node.js installations:

```sh
rm -rf "$HOME/.nvm"
```

Remove Homebrew's download cache. Homebrew recreates it when needed:

```sh
rm -rf "$HOME/Library/Caches/Homebrew"
```

Delete all Minikube profiles and purge its home directory using Minikube's
supported command:

```sh
minikube delete --all --purge
```

Check reclaimed space:

```sh
df -h /System/Volumes/Data
```

## Archive Set

Final names should include a UTC timestamp and machine identifier. The names
below describe the logical contents.

| Archive | Contents |
| --- | --- |
| `projects.tar.zst.age` | Complete `~/projects`, including `.git` and ignored files |
| `workspaces.tar.zst.age` | Complete `~/workspaces` |
| `personal.tar.zst.age` | Documents, Desktop, Pictures, Movies, and Music |
| `downloads.tar.zst.age` | Downloads, kept separate for easier later cleanup |
| `browser-<name>.tar.zst.age` | One archive per browser profile |
| `opencode-raw.tar.zst.age` | Consistent OpenCode database and state assets |
| `opencode-exports.tar.zst.age` | Session JSON exports and project mapping manifest |
| `zed-agent.tar.zst.age` | Native Zed Agent database, portable extracts, and thread metadata |
| `codex-agent.tar.zst.age` | Codex-owned sessions used by Zed external-agent history |
| `developer-history.tar.zst.age` | Selected Fish, database CLI, zoxide, and Lazygit history |
| `raycast-state.tar.zst.age` | Encrypted emergency copy of local Raycast databases and state |
| `apple-local-state.tar.zst.age` | Protected Apple data selected after cloud-sync verification |
| `app-state.tar.zst.age` | Curated OBS, GIMP, Steam, ScreenRecordings, and other selected state |
| `credentials.tar.zst.age` | SSH and GPG material with permissions preserved |

Do not put the age private identity inside an archive encrypted only to that
identity. Store the private identity in Bitwarden and test retrieval before
creating the final backup. Record only the public recipient in backup metadata.

## Retained Roots

- `~/Documents`
- `~/projects`
- `~/workspaces`
- `~/Desktop`
- `~/Downloads`
- `~/Pictures`
- `~/Movies`
- `~/Music`
- `~/Library/ScreenRecordings`

The `projects` and `workspaces` archives must retain symlinks, permissions,
hidden files, uncommitted work, unpushed branches, worktrees, and repository
metadata. Do not replace them with fresh clones during backup.

The rebuilt machine should use the fresh GitHub clone of
`~/projects/dotfiles`; avoid overwriting it with the older copy from the
projects archive.

## Exclusions

- `~/go/bin` and `~/go/pkg`
- `~/Exercism`
- `~/zmk-config`
- `~/OrbStack`
- `~/VirtualBox VMs`
- Homebrew cellar and caches
- `.cache` directories
- `node_modules` outside intentionally retained project trees
- `.rustup`, `.cargo` tool downloads, `.nvm`, `.pyenv`, and language caches
- Neovim plugin and Mason download directories
- Firenvim configuration
- VS Code local History, workspaceStorage, globalStorage, and backups
- zsh and bash histories
- Node, Python, IPython, and other language REPL histories
- Vim, Neovim, and LazyVim session/history state
- Claude, Gemini, Antigravity, and Codeium histories
- WhatsApp and Zalo local databases and media
- DBeaver, SQL/HTTP GUI client, and IINA local state
- User-installed fonts and keyboard layouts
- Sandboxed app Documents outside explicitly retained roots
- Trash and logs

Do not use a broad exclusion against `projects` or `workspaces`; project-local
generated files remain because those roots were explicitly selected for
as-is preservation.

## Browser State

Preserve history and settings for Safari, Chrome, Edge, Firefox, Arc, and any
Brave profile that still exists. Edge is archived even though it will not be
reinstalled automatically.

| Browser | Primary state |
| --- | --- |
| Chrome | `~/Library/Application Support/Google/Chrome` and its preferences |
| Edge | `~/Library/Application Support/Microsoft Edge` and its preferences |
| Firefox | `~/Library/Application Support/Firefox` |
| Arc | `~/Library/Application Support/Arc` and its preferences |
| Safari | Safari library, container, and group-container state |
| Brave | Existing Brave profile directories, if present |

Before copying browser data:

1. Verify browser sync where available.
2. Export bookmarks separately.
3. Record installed extensions.
4. Quit every browser completely.
5. Grant the backup terminal Full Disk Access for Safari data.
6. Exclude disposable browser cache directories while retaining profiles,
   history databases, bookmarks, preferences, extensions, favicons, and
   session metadata.

After reset, use browser sync first. Raw profile archives are recovery sources,
not directories to overwrite onto a running fresh browser. Chromium cookies
and passwords may be tied to the old Keychain; use Bitwarden or browser sync
rather than relying on raw credential databases.

## Application State

Preserve user-created state rather than whole application support trees:

| Application | State |
| --- | --- |
| OpenCode | See `opencode.md` |
| Zed Agent and Codex | See `zed.md` |
| VS Code | Do not archive local state; configure fresh after reinstall |
| OBS | Scenes, profiles, and plugin configuration; omit logs and updates |
| GIMP | Brushes, palettes, plugins, and user configuration |
| Steam | `userdata` only; redownload games and application files |
| Raycast | Encrypt `~/Library/Application Support/com.raycast.macos` as emergency state; use Sync first |

## Selected Developer History

Include only these paths in `developer-history.tar.zst.age`:

- `~/.local/share/fish/fish_history`
- `~/.sqlite_history`
- `~/.psql_history`
- `~/.mysql_history`
- `~/Library/Application Support/zoxide/db.zo`
- `~/Library/Application Support/lazygit/state.yml`

These files are small but can contain commands, paths, and SQL statements with
secrets. Encrypt the archive and restore individual files only after review.

## Raycast State

Raycast's local support directory is about 315 MB and can contain clipboard,
search, AI, activity, extension, and other database state. Create an encrypted
emergency archive only after rotating the exposed Raycast token.

Do not archive `~/.config/raycast/config.json` as a normal restore file. If it
is retained inside an emergency payload for forensic completeness, never copy
its token into the new profile. Configure Raycast through Sync first and use
the raw archive only to recover a specific missing item.

## Apple Protected Data

Grant the backup terminal Full Disk Access for the verification and backup
stage. Check cloud/account settings before deciding which local stores enter
`apple-local-state.tar.zst.age`:

- Messages and attachments
- Mail, especially On My Mac, POP, local drafts, and Mail Downloads
- Notes, especially On My Mac notes and attachments
- Voice Memos
- Contacts, calendars, and reminders
- Local iPhone/iPad backups under MobileSync
- Keychains and local certificates not covered by iCloud Keychain

Cloud verification is a gate, not an assumption. Do not archive a large synced
store solely because it exists, but do not treat privacy-protected zero-byte
measurements as empty. Apple data and Keychains require strong encryption and
careful selective restoration.

Reauthenticate Bitwarden, Google Drive, Tailscale, communication applications,
and coding agents. Record paid application licenses or recovery details in
Bitwarden.

## Credentials

- Archive `~/.ssh` and any GPG private material separately with file modes
  preserved.
- Confirm GitHub, Google, Apple Account, and Bitwarden two-factor recovery from
  another device or browser session.
- Do not commit private keys, `rclone.conf`, age identities, auth tokens, or
  unredacted manifests.
- Rotate the exposed Raycast token before final backup.

## Backup Manifest

For every archive, record outside the encrypted payload:

- Archive filename
- Creation time in UTC
- Source roots
- Uncompressed source byte count
- Source file count
- Encrypted archive byte count
- SHA-256 checksum
- age public recipient fingerprint
- rclone destination path
- Upload and verification time

The manifest must not contain credentials or transcript content.

At the backup-run level, also record the final dotfiles branch and commit used
by the restore-planning session. This lets the fresh clone be checked against
the conversation before that session is resumed.

## Required Verification

1. Confirm the actual Google account quota in the web interface.
2. Confirm rclone reports every upload successful.
3. Compare the remote object size and checksum where supported.
4. Download each archive, or at minimum stream it back through checksum
   verification.
5. Decrypt and list every archive without errors.
6. Fully extract representative personal, Git, credential, browser, and
   OpenCode data into a temporary location.
7. Open representative documents and media.
8. Run Git integrity checks on representative restored repositories.
9. Confirm the age identity can be retrieved from Bitwarden after signing out
   locally.
10. Preserve the verification manifest in Google Drive and the dotfiles issue
    or execution notes.

Any mismatch, unreadable archive, missing identity, sync error, or account
recovery uncertainty blocks the erase.
