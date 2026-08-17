# Omarchy 4 Migration Handoff

Update this note manually immediately before rebooting, changing agents, or
ending a session. It is intentionally short so a new agent can resume without
trusting an old conversation.

## Current status

- Branch: `migrate/omarchy-4`, currently ten commits ahead of
  `origin/migrate/omarchy-4`; unrelated local changes to Mise and Starship are
  intentionally left uncommitted.
- Last completed phase: Phase 5 restoration is in progress. Groups 1/3
  (scaling), 2 (fcitx environment), 4 (terminal preferences), 5 (Hyprland
  bindings/workspaces), and 6 (look/layout) are ported. Group 8 is ported in
  `c311003`: Fish and Delta now use the v4 state path and update on `theme-set`;
  Bat follows the themed terminal through `BAT_THEME=ansi`; custom Neovim uses
  v4 state and passed headless startup. Group 9 uses native Quickshell; the
  remaining regular v3 `hyprlock.conf` was moved recoverably to
  `~/.local/state/dotfiles-omarchy4/20260815T164720Z/legacy/hyprlock.conf`.
  Quickshell is healthy, `hyprctl configerrors` is clean, and the active
  configuration contains no retired desktop references. Group 7's custom rbw
  lock integration and its lock/suspend acceptance are explicitly out of scope
  at the user's direction; no custom plugin is installed.
- Next action: perform the remaining normal Phase 4/6 human checks for menu,
  launcher, notifications, audio, network, terminals, mail, and SSH before
  final acceptance.
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
