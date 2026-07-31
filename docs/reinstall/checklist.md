# Reinstall Checklist

Use this checklist while following [`manual.md`](manual.md); it is an evidence
gate, not a second procedure.

Do not erase the Mac until every item under **Erase Gate** is checked. A future
automation script may produce evidence for these checks, but it must not mark
them complete automatically without validation.

## Documentation and Automation

- [ ] Review `docs/reinstall/manual.md` from start to finish.
- [ ] Consult focused reference documents only when `manual.md` directs it.
- [ ] Review `docs/reinstall/fast-path.md` if using the optional OpenCode-first
      branch.
- [ ] Review `Brewfile` and `Brewfile.mas` for unwanted software.
- [ ] Review the direct backup commands and their recorded evidence.
- [ ] Implement and review curated macOS defaults.
- [ ] Make Kanata use the active home path.
- [ ] Make active Fish configuration match the selected software.
- [ ] Add and test mise activation.
- [ ] Push every dotfiles commit to `origin/main`.
- [ ] Clone the repository into a temporary directory and inspect it.

## Manual Preparation

- [x] Free at least 35-40 GB of local disk space; 49 GiB is available.
- [ ] Empty Trash only after reviewing it.
- [ ] Rotate the Raycast access token.
- [ ] Verify Bitwarden login and two-factor recovery independently.
- [ ] Verify Google account login, two-factor recovery, and actual Drive quota.
- [ ] Verify Apple Account and App Store login.
- [ ] Verify GitHub login and recovery.
- [ ] Inventory application license keys and store them in Bitwarden.
- [ ] Confirm the new short name will be `quangdn`.
- [ ] Confirm no additional data root needs preservation.

## Encryption Preparation

- [ ] Install or make available `age`, `zstd`, and `rclone`.
- [ ] Generate a dedicated age identity for this backup.
- [ ] Store the age private identity in Bitwarden.
- [ ] Record the public age recipient in the backup manifest.
- [ ] Retrieve the identity from Bitwarden in an independent test.
- [ ] Encrypt and decrypt a test archive.
- [ ] Configure a dedicated rclone Google Drive remote without committing its
      credentials.
- [ ] Upload, download, checksum, and decrypt a test archive.

## Data Preparation

- [ ] Review Documents, Desktop, Downloads, Pictures, Movies, and Music.
- [ ] Confirm `projects` and `workspaces` are the complete project roots.
- [ ] Push all desired Git commits and branches while preserving uncommitted
      and ignored files in the archive.
- [ ] Verify browser sync for Safari, Chrome, Edge, Firefox, and Arc.
- [ ] Check for a remaining Brave profile.
- [ ] Export browser bookmarks and record extensions.
- [x] Confirm VS Code local History and workspace state are intentionally
      excluded.
- [ ] Verify Steam Cloud where applicable.
- [ ] Review OBS scenes/profiles and GIMP user resources.
- [ ] Locate SSH and GPG credentials.
- [ ] Verify Fish, database CLI, zoxide, and Lazygit history paths.
- [x] Confirm zsh/bash, REPL, Vim/Neovim, extra AI, and GUI database-client
      histories remain intentionally excluded.
- [ ] Verify Raycast Sync and confirm the rotated token is no longer valid.
- [ ] Verify WhatsApp and Zalo account/cloud recovery; do not archive local
      databases or media.
- [ ] Grant the backup terminal Full Disk Access.
- [ ] Verify cloud/local status for Messages, Mail, Notes, Voice Memos,
      contacts, calendars, reminders, MobileSync backups, and Keychain.
- [ ] Select only required local Apple stores for encrypted backup.
- [ ] Confirm `~/Library/ScreenRecordings` is included.

## OpenCode Preparation

- [ ] Record the final OpenCode version and state path.
- [ ] Dynamically inventory all sessions and project mappings.
- [ ] Export every session to unsanitized JSON inside encrypted staging.
- [ ] Verify export count equals session count.
- [ ] Create and checksum the encrypted export archive.
- [ ] Exit every OpenCode TUI, server, and agent before raw backup.
- [ ] Create a consistent SQLite backup.
- [ ] Run SQLite integrity checking on the copied database.
- [ ] Archive the raw database, storage, snapshots, and tool output.
- [ ] Include authentication only in the encrypted emergency archive.
- [ ] Verify both OpenCode archives after remote download.
- [ ] Finish all restore-planning work in the current OpenCode session.
- [ ] Commit and push the exact dotfiles state used by the current session.
- [ ] Quit the current OpenCode TUI before creating the final portable exports
      and raw backup.
- [ ] Confirm the current planning session is present in the encrypted portable
      export manifest and has a valid JSON export.
- [ ] Test-decrypt the portable export archive and verify the planning session
      can be located by its recorded ID.

## Zed and Codex Agent Preparation

- [ ] Record final Zed and Codex versions.
- [ ] Inventory native Zed Agent thread count.
- [ ] Inventory Zed sidebar entries by agent owner.
- [ ] Inventory Codex thread-index and session-file counts.
- [ ] Quit Zed and stop every Codex/ACP process.
- [ ] Create consistent backups of native and stable Zed databases.
- [ ] Export native Zed rows as encrypted portable JSON and metadata.
- [ ] Create a curated Codex state archive with auth reserved for emergency
      recovery only.
- [ ] Run integrity checks on every copied Zed and Codex database.
- [ ] Record every old-home path that requires migration.
- [ ] Verify Zed and Codex archives after remote download.

## Backup Creation

- [ ] Create the projects archive.
- [ ] Create the workspaces archive.
- [ ] Create the personal-data archive.
- [ ] Create the downloads archive.
- [ ] Create one archive per browser.
- [ ] Create the application-state archive.
- [ ] Create the selected developer-history archive.
- [ ] Create the encrypted Raycast emergency archive.
- [ ] Create the selected Apple local-state archive, if required.
- [ ] Create the native Zed Agent archive.
- [ ] Create the Codex agent archive.
- [ ] Create the credentials archive.
- [ ] Record source sizes, file counts, archive sizes, and SHA-256 checksums.
- [ ] Upload every archive with rclone.
- [ ] Confirm there are no Google Drive or rclone errors.
- [ ] Validate remote sizes and checksums.
- [ ] Download or stream-verify every encrypted archive.
- [ ] Decrypt and list every archive.
- [ ] Fully test representative restored files and repositories.

## Erase Gate

- [ ] All selected source roots are represented in the manifest.
- [ ] Every archive passes local and remote verification.
- [ ] The age identity is recoverable without relying on this Mac.
- [ ] Bitwarden, Google, Apple, and GitHub recovery are verified.
- [ ] The dotfiles repository is pushed and independently cloneable.
- [ ] Browser history/settings have both sync and encrypted fallback coverage.
- [ ] OpenCode has portable exports and a valid raw backup.
- [ ] The current planning session is in the verified portable export archive,
      and its final runbook commit is pushed.
- [ ] Native Zed Agent threads and Codex sessions have valid encrypted backups.
- [ ] No upload, Git push, or cloud sync is pending.
- [ ] An explicit final approval to erase has been given.

## Reset and Initial Setup

- [ ] Use Erase All Content and Settings.
- [ ] Create the `quangdn` account.
- [ ] Do not use Migration Assistant.
- [ ] Sign in to the Apple Account and App Store.
- [ ] Enable FileVault and store its recovery key.
- [ ] Install pending macOS updates.
- [ ] Resume at the post-reset section of `docs/reinstall/manual.md`.
- [ ] Optionally use `docs/reinstall/fast-path.md` before the remaining restore.
- [ ] Resume the exported OpenCode session on the exact dotfiles commit.

## Bootstrap

- [ ] Install Xcode Command Line Tools.
- [ ] Install Homebrew.
- [ ] Install Git and GitHub CLI.
- [ ] Clone dotfiles into `~/projects/dotfiles`.
- [ ] Apply `Brewfile`.
- [ ] Apply `Brewfile.mas` after App Store login.
- [ ] Deploy `shared` and `macos` with Stow.
- [ ] Set Fish as the login shell and synchronize Fisher plugins.
- [ ] Install global Python 3.12, Go 1.26, and shared Go tools through mise.
- [ ] Synchronize both Neovim configurations.
- [ ] Apply curated macOS defaults.
- [ ] Install and approve Kanata last.

## Restore

- [ ] Restore retained personal data.
- [ ] Restore projects and workspaces without replacing the fresh dotfiles
      clone.
- [ ] Restore SSH/GPG files with correct permissions.
- [ ] Restore browser data through sync first.
- [ ] Restore curated application state.
- [ ] Restore selected developer history after reviewing decrypted files.
- [ ] Configure Raycast through Sync before consulting its emergency archive.
- [ ] Restore selected local-only Apple data after account synchronization.
- [ ] Restore `~/Library/ScreenRecordings`.
- [ ] Import OpenCode sessions from mapped project directories.
- [ ] Restore native Zed Agent threads from a migrated database copy.
- [ ] Restore Codex state and import its sessions through Zed Thread History.
- [ ] Reauthenticate OpenCode providers.
- [ ] Reauthenticate other applications instead of copying old tokens.

## Final Verification

- [ ] `brew bundle check --file=Brewfile` passes.
- [ ] Homebrew has no unwanted or broken services.
- [ ] Fish starts without missing-command errors.
- [ ] `mise doctor` passes; Python and Go resolve to the declared global tracks.
- [ ] Shared Go tools resolve through mise.
- [ ] Node.js, Rust, Zig, and Java are not selected as global development
      runtimes unless a project has explicitly requested them.
- [ ] Both Neovim configurations start and pass relevant health checks.
- [ ] Ghostty, FlashSpace, and Kanata work.
- [ ] Browser history, bookmarks, settings, and extensions are available.
- [ ] OpenCode session counts and representative sessions are verified.
- [ ] Native Zed and Codex session counts and representative sessions are
      verified.
- [ ] Retained data matches the backup manifest.
- [ ] FileVault is enabled.
- [ ] Bootstrap can be rerun without harmful changes.
- [ ] Encrypted backup retention date is recorded at least 90 days ahead.
