# Omarchy scaling policy and rollback notes

This is the durable record of the scaling setup established during the Omarchy
4 migration. It intentionally lives outside `reinstall/omarchy4/handoff.md` and
outside the temporary migration runbook so it remains available after migration
cleanup.

## Current policy

The reference point is:

- Hyprland monitor scale: `1`
- Omarchy shell `base-size`: `14`
- GTK text scale: `1.5`
- Alacritty and Kitty effective font size: `16`
- Ghostty configured font size: `10.6667`, which becomes effectively `16` after
  GTK text scaling

The tracked implementation is:

- `linux/.local/bin/omarchy-display-text-size`
- `linux/.config/omarchy/plugins/quangdn.monitor/`

The terminal and GTK values follow these formulas:

```text
terminal_size = base_size / 14 * 16
gtk_text_scale = base_size / 14 * 1.5
ghostty_configured_size = terminal_size / gtk_text_scale
```

The custom monitor panel is an official Omarchy plugin clone. It exists because
the packaged panel invokes the packaged display-size helper directly; the clone
changes that call to `~/.local/bin/omarchy-display-text-size`. After a material
Omarchy upgrade, compare it with
`/usr/share/omarchy/shell/plugins/panels/monitor` for upstream changes.

## Removed application-specific overrides

Omarchy 4's stock Chromium scaling currently works correctly, so application
force-scaling flags were removed. Keep this as the quick restoration reference
if an application later proves to need one.

### Electron

The former global file was `linux/.config/electron-flags.conf` with:

```text
--force-device-scale-factor=1.5
```

`linux/.config/spotify-flags.conf` and
`linux/.config/typora-flags.conf` were symlinks to `electron-flags.conf`.
Restore the global file only if several Electron applications need the same
override. Prefer an application's own flags file when only that application is
wrong. Fully quit and relaunch the application after changing flags.

### Qt and Steam

The former `linux/.config/environment.d/dotfiles-scale.conf` contained:

```text
STEAM_FORCE_DESKTOPUI_SCALING=1.5
QT_SCALE_FACTOR=1.5
```

These are session environment variables, so adding or removing them requires a
full logout and login. The user systemd manager may continue to report the old
values until that new session begins.

### Chromium, Chrome, and Brave

Chromium now uses Omarchy's stock `~/.config/chromium-flags.conf`; do not add a
force factor unless testing demonstrates a real problem. Restore the stock file
with:

```sh
omarchy refresh config chromium-flags.conf
```

The retired tracked Chrome and Brave Beta flag files did not contain a scaling
factor. They referenced the old Omarchy 3 extension location, so do not restore
them verbatim on Omarchy 4.

## Recovery sources

- Exact pre-upgrade state: branch `archive/omarchy-3.8.4-pre-quattro`
- First Omarchy 4 work-in-progress snapshot: commit `da15cf5`

Use those sources for comparison; reapply only the smallest override needed by
the affected application.
