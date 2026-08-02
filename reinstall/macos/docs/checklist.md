# Reinstall Gate Reference

This is a reusable human reference, not live run state. The authoritative state
is `run.json`, receipts, and events under
`~/.local/state/dotfiles-reinstall/runs/<run-id>/`. Use the repository's
`reinstall/macos/bin/reinstall status` command.

Run state uses `active`, `blocked_human`, and `completed`; gate records use
`pending`, `passed`, and `superseded`. Archive dispositions separately represent
`encrypted_archive`, `sync_only`, and `intentionally_skipped`. A checked
Markdown box cannot provide enough evidence for an erase decision.

## Pre-Erase Gates

| Gate ID | Human evidence required |
| --- | --- |
| `recovery_accounts` | Apple, Bitwarden, Google, and GitHub recovery works independently of this Mac |
| `recovery_age` | The age identity is recoverable and decrypts a test archive |
| `cleanup_review` | Every immutable cleanup candidate is regenerable; Downloads was reviewed manually |
| `archive_plan_review` | Resolved sources, exclusions, missing paths, counts, and required stopped apps are accepted |
| `agent_state` | OpenCode, Zed, and Codex manual capture adapters produced valid registered archives |
| `representative_restore` | Remote copies were downloaded, validated, extracted privately, and representative files/repositories were tested |
| `sync_only_recovery` | Safari and selected Apple data are accepted through sync, or an encrypted local archive was added |
| `erase_approval` | All blockers are closed and the operator explicitly authorizes manual erase |

## Post-Erase Gates

| Gate ID | Human evidence required |
| --- | --- |
| `setup_assistant` | `/Users/quangdn` exists, Migration Assistant was skipped, and updates are installed |
| `account_login` | Apple, App Store, Bitwarden, Google Drive, GitHub, Tailscale, and providers are reauthenticated as needed |
| `browser_sync` | Bookmarks, history, settings, and extensions are accepted before consulting raw profiles |
| `raycast_sync` | Raycast Sync was attempted before consulting its emergency archive |
| `privacy_permissions` | Kanata Driver Extension, Input Monitoring, Accessibility, and other required permissions work |
| `restore_apply` | Staged restore conflict reports were reviewed before copying missing files |
| `agent_sessions` | OpenCode, native Zed, and Codex counts and representative sessions are accepted |
| `filevault` | FileVault is enabled and its new recovery key is stored without recording it in evidence |
| `final_acceptance` | Representative data and applications work; archive retention end date is recorded |

## Automated Evidence

The script records these without human checkboxes:

- Tool, platform, key-recipient, and configuration preflight
- Immutable cleanup-plan checksum and deletion receipt
- Source paths, logical bytes, file counts, and archive-plan checksums
- Atomic encrypted archive creation
- Local checksum and decrypt/list validation
- Complete remote-stream checksum validation
- Manifest and cross-erase resume metadata digests
- Archive path, link-target, duplicate-entry, and member-type safety checks
- Staged restore inventory, conflict report, and no-overwrite apply receipt
- Brew, Stow, mise, uv, defaults, and final bootstrap command results

If automation fails, follow the matching manual fallback section in
[`manual.md`](manual.md) and retain its output as a receipt. Do not mark a gate
passed merely because a command was attempted.
