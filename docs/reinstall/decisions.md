# Reinstall Decisions

This is a decision reference, not an execution guide. Start with
[`manual.md`](manual.md).

This document records the decisions agreed before implementation. Future work
should not silently expand the software or restore scope.

## Machine and Reset

| Item | Decision |
| --- | --- |
| Architecture | Apple Silicon (`arm64`) |
| Observed macOS | macOS 26.5.2 at planning time |
| Reset method | Erase All Content and Settings |
| Existing account | `/Users/quang-dang` |
| New account | `/Users/quangdn` |
| Full home restore | No |
| Migration Assistant | Do not use |
| FileVault | Re-enable and verify after reset |

Erase All Content and Settings retains the sealed operating system but erases
installed applications, settings, users, data, and all volumes. Selected files
therefore must leave the internal disk before reset.

## Backup

| Item | Decision |
| --- | --- |
| Backup destination | Google Drive |
| Second provider or disk | None currently available |
| Encryption | age recipient encryption |
| age identity recovery | Store the private identity in Bitwarden |
| Archive form | Logical tar archives compressed with zstd and encrypted with age |
| Transfer | rclone |
| Desired free space | 35-40 GB minimum; about 50 GB preferred |
| Retention | At least 90 days after successful rebuild |

Google Drive is the only backup provider, so remote checksum validation and a
real download/decryption test are blocking erase requirements.

## Retained User Data

- `~/Documents`
- `~/projects`
- `~/workspaces`
- `~/Desktop`
- `~/Downloads`
- `~/Pictures`
- `~/Movies`
- `~/Music`
- Browser history and settings for every existing browser
- OpenCode sessions and selected OpenCode state
- Native Zed Agent threads and Zed thread metadata
- Codex sessions needed by Zed's external-agent Thread History
- Fish command history
- Database CLI histories for SQLite, PostgreSQL, and MySQL
- zoxide directory-frequency history
- Lazygit recent-repository and UI state
- An encrypted Raycast emergency copy
- `~/Library/ScreenRecordings`
- Apple local/protected data that remains important after verifying cloud sync
- Selected application-created data described in `backup.md`
- SSH and GPG credentials, encrypted separately

## Intentionally Regenerated or Removed

- Homebrew installation and cellar contents
- `~/go/bin` and `~/go/pkg`
- `~/Exercism`
- `~/zmk-config`
- OrbStack and VirtualBox state
- Language runtime installations and caches
- `node_modules`, Python virtual environments, Mason downloads, and editor
  plugin downloads outside retained projects
- Firenvim configuration
- General caches and logs
- Whole-home and whole-`~/Library` restoration
- VS Code local History, workspaceStorage, globalStorage, backups, and chat state
- zsh, bash, language REPL, Vim, Neovim, and LazyVim session/history state
- Claude, Gemini, Antigravity, and Codeium histories
- WhatsApp and Zalo local databases and media; rely on their account/cloud state
- DBeaver, SQL/HTTP GUI client, and IINA local state
- User-installed fonts, keyboard layouts, and sandboxed app Documents outside
  the selected roots

The retained `projects` and `workspaces` trees are copied as data, including
uncommitted files and repository metadata. Cleanup inside those roots is not
part of the OS reset.

## Active Software Choices

| Category | Decision |
| --- | --- |
| Terminal | Ghostty |
| Workspace manager | FlashSpace |
| Keyboard remapper | Kanata |
| Shell | Fish with Tide |
| Editors | Custom Neovim, LazyVim, Zed, Visual Studio Code |
| File listing | `lsd` |
| Browsers to reinstall | Chrome, Firefox, Arc, and built-in Safari |
| OpenCode | Install with the official Homebrew tap and restore sessions |
| Terminal mail | Keep configuration only; do not install initially |

Tracked configurations for uninstalled applications remain in the repository
for possible future use. They are not evidence that the corresponding software
belongs in the install manifest.

## Dormant Configurations

Do not automatically install these solely because configuration exists:

- WezTerm and Kitty
- AeroSpace and Amethyst
- Karabiner-Elements
- Hammerspoon and SketchyBar
- Helix
- Starship
- spotify-player
- aerc, isync, notmuch, and msmtp
- SVim and borders

## Development Runtime Policy

- mise owns language runtimes.
- Global mise config declares `python = "3.12"`, intentionally following the
  newest available Python 3.12 patch.
- Global mise config declares the Go 1.26 track and pinned Go development tools
  used by the editor configs: `gopls`, `gofumpt`, `goimports`,
  `gomodifytags`, `impl`, and Delve.
- Node.js, Rust, and Zig are installed as development runtimes only from
  project `mise.toml` files. Homebrew may install Node.js as a dependency of
  globally shared editor tools; it is not the selected project runtime.
- `projects/uucode/mise.toml` already declares Zig and hyperfine.
- Projects without a mise declaration are updated only when actively used; the
  OS bootstrap does not guess their runtime versions.
- Homebrew owns shared editor CLI tools when practical. Mason appends its bin
  directory to Neovim's PATH and installs only missing fallbacks or
  editor-private debug adapters.

## macOS Defaults

The future defaults script should preserve these reviewed behaviors:

- Dock auto-hide enabled.
- Dock tile size 56.
- Recent applications hidden in the Dock.
- Windows minimized into the application icon.
- Spaces not automatically reordered by recent use.
- Finder defaults to column view.
- Finder path bar shown.
- Finder status bar hidden.
- Filename extension behavior left at the macOS default.
- Key repeat value 5 and initial repeat value 15.
- Press-and-hold accents disabled in favor of key repeat.
- Trackpad tap-to-click enabled.
- Trackpad three-finger drag enabled.
- Screenshots saved as PNG under `~/Pictures/Screenshots`.

Do not dump and replay entire preference domains.

## OpenCode

- Preserve both portable session exports and a raw emergency state backup.
- Use the current dotfiles session's normal portable export to resume the agent
  before the full restore; do not create a separate handoff archive or script.
- Reauthenticate providers after reset instead of restoring credentials by
  default.
- Record the OpenCode version during final backup.
- Import sessions from their restored project directories so paths bind to
  `/Users/quangdn`.
- Keep raw state encrypted because it can contain prompts, source excerpts,
  account data, and provider credentials.

## Zed Agents

- Preserve native Zed Agent threads through a consistent database backup and
  portable encrypted extracts.
- Preserve Zed's thread-sidebar metadata without restoring the complete Zed
  editor database by default.
- Preserve Codex's own session store because Zed does not own the content of
  `codex-acp` sessions.
- Reauthenticate Zed providers and Codex after reset.
- Rebind all session and worktree paths from `/Users/quang-dang` to
  `/Users/quangdn` in restore copies only.
- Do not restore downloaded Zed extensions, language servers, external-agent
  packages, Node runtimes, debug adapters, Prettier, or caches.

## Other Session and History State

- Preserve only Fish history, database CLI histories, zoxide, and Lazygit from
  the small developer-history category.
- Do not preserve VS Code local state. Reconfigure it after reinstall; cloud
  Settings Sync may be used but is not a backup dependency.
- Preserve Raycast's local support database only as an encrypted emergency
  archive. Restore through Raycast Sync first and never restore the old exposed
  token.
- Rely on WhatsApp and Zalo account/cloud recovery rather than archiving their
  approximately 5.5 GB of local state.
- Verify Messages, Mail, Notes, Voice Memos, contacts, calendars, reminders,
  local device backups, and iCloud Keychain. Archive only protected/local data
  that is not safely synchronized.
- Preserve `~/Library/ScreenRecordings`; do not preserve custom fonts,
  keyboard layouts, or unidentified sandboxed app Documents.
- Keep `~/zmk-config` and `~/Exercism` excluded as previously decided.

## Security Actions

- Rotate the Raycast token found in `~/.config/raycast/config.json` before
  creating backups.
- Verify Bitwarden access and two-factor recovery independently of this Mac.
- Store the age private identity in Bitwarden. The public recipient may be
  recorded in a local backup manifest.
- Never commit `auth.json`, rclone credentials, age identities, browser
  profiles, session exports, or generated backup manifests containing private
  paths or metadata.
