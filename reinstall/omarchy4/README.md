# Omarchy 4.0 Migration Runbook

This is a one-time, manual migration from Omarchy 3.8.4 to stable 4.0.0. It
does not provide migration scripts or a second configuration manager. An agent
executes the steps interactively, stops at each human gate, and records the
last completed phase in [`handoff.md`](handoff.md) before any reboot.

Omarchy 4 replaces Waybar, Walker, Mako, SwayOSD, Hypridle, Hyprlock, and the
old Hyprland `.conf` setup with a Quickshell desktop and Lua-based Hyprland user
files. Treat the old configuration as evidence of desired outcomes, not as a
payload to copy forward. Read the official [4.0.0 release notes](https://github.com/basecamp/omarchy/releases/tag/v4.0.0), [file layout](https://github.com/basecamp/omarchy/blob/quattro/docs/file-layout.md), and [shell documentation](https://github.com/basecamp/omarchy/blob/quattro/docs/omarchy-shell.md) at the relevant steps.

## Read First

1. Read [`groups.md`](groups.md). It is the authoritative inventory and tells
   the agent what to leave alone, test natively, port, or remove.
2. Read [`rollback.md`](rollback.md) before creating any checkpoint.
3. Confirm that `main` is clean and pushed, and that the known pre-upgrade
   commit `b619904` (`use local keyring for aerc synced from rbw`) is an
   ancestor of `main`.
4. Use [`handoff.md`](handoff.md) after a reboot or a change of agent. It is a
   small manually maintained note, not automation.

## Phase 1: Git and local recovery points

Create and push an immutable source archive before changing tracked Linux
configuration:

```sh
git switch main
git status --short --branch
git fetch origin
git rev-parse HEAD
git log --oneline origin/main..main
git branch archive/omarchy-3.8.4-pre-quattro b619904
git push origin archive/omarchy-3.8.4-pre-quattro
git switch -c migrate/omarchy-4
```

Stop if `main` is not clean, not pushed, or does not contain `b619904` in its
history. The archive branch is the permanent exact-copy restoration source; do
not keep obsolete copies on `main` merely as a backup.

Create a timestamped working directory outside the repository, for example
`~/.local/state/dotfiles-omarchy4/20260815T120000Z/`. Store there:

- `git-revision.txt`, `omarchy-version.txt`, `findmnt.txt`, and `lsblk.txt`;
- a checksum inventory of the tracked `linux` and `shared` trees;
- command output for every checkpoint and validation step;
- a copy of the final `handoff.md` note if a later agent needs context.

A safe starting inventory is:

```sh
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$HOME/.local/state/dotfiles-omarchy4/$RUN_ID"
mkdir -p "$RUN_DIR"
git rev-parse HEAD >"$RUN_DIR/git-revision.txt"
omarchy version >"$RUN_DIR/omarchy-version.txt"
{
  findmnt -no SOURCE,FSTYPE,OPTIONS /
  findmnt -no SOURCE,FSTYPE,OPTIONS /home
} >"$RUN_DIR/findmnt.txt"
lsblk -f >"$RUN_DIR/lsblk.txt"
git ls-files -z -- linux shared | xargs -0 sha256sum >"$RUN_DIR/dotfiles-sha256.txt"
```

Create three same-disk recovery points, then verify their identifiers and
readability:

1. Run `omarchy snapshot create` for the configured Snapper root snapshots.
2. Make a read-only Btrfs snapshot of the separate `@home` subvolume. Mount the
   Btrfs top-level only long enough to create and identify that snapshot; record
   its exact subvolume path and ID. Do not guess the backing device or snapshot
   location.
3. Archive `/boot` with ACLs and xattrs into the working directory, compress it,
   and record a SHA-256 checksum. Create this archive before the `@home`
   snapshot so it is covered by the home checkpoint.

On this machine, confirm first that `findmnt.txt` identifies `/dev/mapper/root`
with root subvolume `@` and home subvolume `@home`. Only then use this exact
checkpoint sequence, substituting the recorded `$RUN_ID` if resuming:

```sh
omarchy snapshot create | tee "$RUN_DIR/omarchy-snapshot-create.txt"
sudo snapper list | tee "$RUN_DIR/snapper-list.txt"

sudo tar --acls --xattrs --numeric-owner -C /boot -cf - . \
  | zstd -T0 -o "$RUN_DIR/boot-pre-omarchy4.tar.zst"
sha256sum "$RUN_DIR/boot-pre-omarchy4.tar.zst" \
  | tee "$RUN_DIR/boot-pre-omarchy4.tar.zst.sha256"

sudo mkdir -p /mnt/dotfiles-omarchy4-btrfs-top
sudo mount -o subvolid=5 /dev/mapper/root /mnt/dotfiles-omarchy4-btrfs-top
sudo btrfs subvolume snapshot -r /home \
  "/mnt/dotfiles-omarchy4-btrfs-top/@home.pre-omarchy4-$RUN_ID"
sudo btrfs subvolume show \
  "/mnt/dotfiles-omarchy4-btrfs-top/@home.pre-omarchy4-$RUN_ID" \
  | tee "$RUN_DIR/home-snapshot.txt"
sudo umount /mnt/dotfiles-omarchy4-btrfs-top
```

Do not copy these commands to a system whose `findmnt` result differs. Record
the snapshot path and its numeric subvolume ID from `home-snapshot.txt` in the
handoff note.

These checkpoints are intentionally local and same-disk. They are recovery
points for a bad upgrade, not protection against disk failure. Keep them until
an explicit final-cleanup decision.

**Human gate:** inspect the Snapper IDs, Btrfs home snapshot ID/path, boot
archive checksum, free space, and pushed archive branch before proceeding.

## Phase 2: Disable only Omarchy overrides

The current repository uses one `linux` Stow package. Do not introduce modular
Stow packages for this one-time operation.

For every path classified as `remove before upgrade` or `port only if needed`
in [`groups.md`](groups.md):

1. Resolve the live path with `readlink -f` and verify it points into this
   repository's `linux` tree.
2. Unlink the live symlink only after that verification. Never remove a regular
   user file using this procedure.
3. Remove the corresponding legacy path from `linux` on `migrate/omarchy-4`.
   The pushed archive branch is its easy restoration source.
4. Restow `linux` only after the legacy paths have been removed, using a Stow
   dry run first. This keeps unrelated Linux configuration—including rbw, mail,
   and SSH-support files—active.

For a removed path that has a stock Omarchy 3.8 default, use the specific
`omarchy-refresh-config <path>` command to recreate only that default file. Do
not run `omarchy-reinstall-configs`: it overwrites broadly and is not needed.

Before the upgrade, prove that none of the updater's likely rewrite targets are
symlinks into this repository. In particular, terminal configuration and old
Hyprland files must be ordinary user files or absent. This prevents the
one-way upgrader from modifying tracked files through a live symlink.

**Human gate:** review the detached-path list against `groups.md`, confirm that
the current desktop still has a usable terminal, and commit the quarantine
change before upgrading.

## Phase 3: Official upgrade and reboot

1. Confirm the stable channel and record `omarchy version`.
2. Run the normal `omarchy update`.
3. Run the official `omarchy-upgrade-to-quattro` upgrade interactively. Do not
   use development flags, automatic approval flags, or source edits under
   `~/.local/share/omarchy` or `/usr/share/omarchy`.
4. Capture its terminal output in the working directory.
5. Update [`handoff.md`](handoff.md) with `Phase 3 complete; reboot pending`
   before rebooting.

The upgrader is one-way. If it fails before a usable desktop is reached, stop
and use the recovery information in [`rollback.md`](rollback.md); do not
attempt a hand-written downgrade.

**Human gate:** inspect the upgrader result and explicitly approve reboot.

## Phase 4: Stock Omarchy 4 acceptance

After reboot, start from [`handoff.md`](handoff.md), not this document's
checkbox-like prose. Confirm:

- Omarchy reports 4.0.0 and its package-backed layout is present.
- Quickshell is healthy (`omarchy-shell shell ping`), and
  `omarchy debug --no-sudo --print` has no migration blocker.
- `hyprctl configerrors` is clean after the stock v4 session loads.
- Menu, launcher, notifications, audio, network, terminal, lock/unlock, and
  suspend/resume work without a restored override.

Record the outputs and update the handoff to `Phase 4 complete; group restore
may begin`.

## Phase 5: Restore by documented group

Work through [`groups.md`](groups.md) in order. For each group:

1. First test the native v4 outcome.
2. If native behavior meets the stated outcome, record `native; legacy removed`
   in the migration commit and do not port the old configuration.
3. Otherwise port the minimum behavior to the documented v4 location, never
   the retired file format.
4. Validate the group, inspect the result, commit the group independently, and
   update [`handoff.md`](handoff.md).

The intended pace is one post-upgrade session with an acceptance pause between
groups. The handoff allows a different agent to continue safely if that session
is interrupted.

## Phase 6: Finalize

Run the final checks in [`groups.md`](groups.md), including the SSH/mail checks
that must still pass while rbw is locked. Verify there are no active references
to the retired components or to `~/.config/omarchy/current` in newly ported
configuration. Push `migrate/omarchy-4` only after the tree is clean.

After explicit final acceptance, remove this temporary documentation from the
active branch in one dedicated cleanup commit:

1. Remove `reinstall/omarchy4/`.
2. Remove the Omarchy 4 entry from `reinstall/README.md`.
3. Remove the `Omarchy 4 Migration` section from `AGENTS.md`.
4. Commit and push the cleanup.

The migration record remains recoverable from Git history, the migration
branch, and the pushed pre-upgrade archive branch. Keep local checkpoints as a
separate decision after several normal reboots and daily use.
