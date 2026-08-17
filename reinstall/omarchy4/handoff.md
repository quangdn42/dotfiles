# Omarchy 4 Migration Handoff

Update this note manually immediately before rebooting, changing agents, or
ending a session. It is intentionally short so a new agent can resume without
trusting an old conversation.

## Current status

- Branch: `migrate/omarchy-4` at `85a484b`, aligned with
  `origin/migrate/omarchy-4`. Former WIP commit `da15cf5` was soft-reset into
  the staging area for review alongside the scaling migration.
- Last completed phase: Phase 3 Quattro upgrade and first reboot completed on
  2026-08-16. The stock-v4 safety subset of Phase 4 is clean. Scaling Groups 1
  and 3 are accepted with a ported scale-1/GDK-1 fallback and the tracked
  `~/.local/bin/omarchy-display-text-size` shim: monitor and GDK scale are 1;
  shell base size 14 maps to GTK text scaling 1.5 and effective terminal size
  16. Ghostty compensates for GTK scaling with a configured size of 10.6667.
  The enabled, tracked `quangdn.monitor` clone invokes the policy by absolute
  user-local path because the stock shell puts `/usr/share/omarchy/bin` first
  in its `PATH`. Chromium uses its ordinary stock v4 flags and scales correctly
  without a forced device factor. Global Electron, Spotify, Typora, Qt, and
  Steam scale overrides were removed; application-specific scaling will only
  be reintroduced if normal use exposes a problem.
- Next action: perform the Phase 4 human acceptance checks for menu, launcher,
  notifications, audio, network, terminal, lock/unlock, and suspend/resume.
  First split and review the staged former-WIP changes; do not commit or restow
  its retired Mako path. Then continue with Group 2 input/session behavior and
  the remaining terminal preferences in Group 4. Revisit application-specific
  scaling only if normal use exposes an issue; do not reintroduce a legacy
  Omarchy source path.
- Working directory: `~/.local/state/dotfiles-omarchy4/20260815T164720Z/`
- Checkpoints: Snapper root snapshot `708` (description `3.8.4`); read-only
  Btrfs `@home` snapshot
  `@home.pre-omarchy4-20260815T164720Z` (subvolume ID `973`); `/boot` archive
  `boot-pre-omarchy4.tar.zst` verifies against its SHA-256 receipt and can be
  decompressed/listed. Inventory includes 214 tracked Linux/shared file
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
