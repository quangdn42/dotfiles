# Omarchy 4 Migration Recovery

Read this before beginning the upgrade. Omarchy's Quattro upgrade is one-way;
recovery means restoring the prepared system checkpoints, not translating
Omarchy 4 files backward by hand.

## Recovery sources

1. `archive/omarchy-3.8.4-pre-quattro` is the exact, pushed configuration
   source at commit `b619904`.
2. The Snapper snapshot created by `omarchy snapshot create` restores the root
   subvolume(s) configured in Snapper.
3. The read-only Btrfs `@home` snapshot restores home separately.
4. The checksummed `/boot` archive restores boot files if the root snapshot
   does not provide the expected boot state.

All are same-disk recovery points. If the disk fails, they fail with it.

The expected recorded topology is `/dev/mapper/root`, with root subvolume `@`
and home subvolume `@home`. Recovery must begin by checking the saved
`findmnt.txt` and the live layout; do not assume this topology on another
machine.

## When to stop and recover

Stop rather than continue if any of these occur:

- the official upgrader fails before a usable desktop is available;
- the display or input path leaves no workable local console/TTY route;
- the system cannot unlock or resume safely after the stock-v4 test;
- package/layout changes leave the system unable to boot normally;
- the archive branch, root snapshot, home snapshot, or boot archive was not
  verified before the upgrade.

Do not run `omarchy-reinstall-configs`, copy old Hyprland `.conf` files over
v4 Lua files, or edit installed Omarchy source as a recovery attempt.

## Restore outline

1. Boot a known-good environment or use the installed snapshot boot entry.
2. Identify the recorded Btrfs filesystem, root/Snapper snapshot, and `@home`
   snapshot by their recorded IDs; never substitute a similarly named snapshot.
3. Restore the Snapper-managed root state using the supported Snapper/Limine
   recovery flow for this installation.
4. Mount the Btrfs top level and restore `@home` from the recorded read-only
   snapshot, preserving the failed `@home` subvolume under a timestamped
   recovery name until the restored system is confirmed usable.
5. Restore `/boot` from the recorded archive only if comparison against the
   restored root state shows it is needed. Verify the archive checksum before
   extraction and preserve the pre-restore boot tree first.
6. Boot the restored system, check `omarchy version`, then compare live symlink
   targets with the archived Git branch before restowing anything.

## Configuration-only restoration

If Omarchy 4 itself is usable and only a group port failed, do not roll back the
whole system. Revert that group's migration commit, detach its live Stow links
after verifying them, and recover the old file from
`archive/omarchy-3.8.4-pre-quattro`. Reapply it only to the restored 3.8.4
system—not to Omarchy 4.

After any recovery, update `handoff.md` with the snapshot IDs used, resulting
boot state, and the next human decision.

## `@home` restore command shape

This is performed only from a live/rescue environment or other state where
`@home` is not mounted. After checking the recorded device, source snapshot,
and top-level mount, the restore has this shape:

```sh
sudo mount -o subvolid=5 /dev/mapper/root /mnt/dotfiles-omarchy4-btrfs-top
sudo mv /mnt/dotfiles-omarchy4-btrfs-top/@home \
  /mnt/dotfiles-omarchy4-btrfs-top/@home.failed-<timestamp>
sudo btrfs subvolume snapshot \
  /mnt/dotfiles-omarchy4-btrfs-top/@home.pre-omarchy4-<recorded-run-id> \
  /mnt/dotfiles-omarchy4-btrfs-top/@home
sudo btrfs subvolume show /mnt/dotfiles-omarchy4-btrfs-top/@home
sudo umount /mnt/dotfiles-omarchy4-btrfs-top
```

Do not delete `@home.failed-<timestamp>` until the restored login, data, and
desktop have been accepted. Extract the boot archive only after verifying its
recorded SHA-256 checksum and only onto a preserved boot tree.
