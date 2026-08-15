# Omarchy 4 Migration Handoff

Update this note manually immediately before rebooting, changing agents, or
ending a session. It is intentionally short so a new agent can resume without
trusting an old conversation.

## Current status

- Branch: `migrate/omarchy-4` at `30b73c5`
- Last completed phase: archive branch pushed at `b619904`; pre-upgrade
  inventory captured; root Snapper and `/boot` checkpoints verified.
- Next action: create and verify the read-only `@home` Btrfs checkpoint
  described in `README.md`. It must snapshot `/home` (the `@home` subvolume),
  not `/home/quangdn`.
- Working directory: `~/.local/state/dotfiles-omarchy4/20260815T164720Z/`
- Checkpoints: Snapper root snapshot `708` (description `3.8.4`); `/boot`
  archive `boot-pre-omarchy4.tar.zst` verifies against its SHA-256 receipt;
  `@home` snapshot pending. Inventory includes 214 tracked Linux/shared file
  checksums.
- Reboot pending: no

## Required handoff fields during execution

Replace the status above with:

- branch and Git commit;
- last completed phase and exact next command or human action;
- working-directory path containing logs/checksums;
- Snapper snapshot IDs, Btrfs `@home` snapshot path/ID, and `/boot` archive
  checksum;
- whether the Quattro upgrader completed and whether reboot is pending;
- each accepted group and whether it was native, ported, or removed;
- unresolved blocker, if any.

Do not record secrets, credentials, recovery keys, or the contents of mail
credentials in this file.

After final acceptance, this handoff and the rest of `reinstall/omarchy4/` are
removed in the documented cleanup commit. Do not preserve them on `main` as a
permanent operational workflow.
