# Kanata LaunchDaemons

These files run Kanata and the standalone Karabiner VirtualHIDDevice daemon at
boot. They are adapted from Kanata's
[macOS setup](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md) and
[sample plists](https://github.com/jtroo/kanata/tree/main/cfg_samples).

The installer copies the plists instead of symlinking them because system
LaunchDaemons should be owned by `root:wheel`, not a user-writable repository.

## Prerequisites

- Kanata is installed at `/opt/homebrew/bin/kanata`.
- The config is available at `$HOME/.config/kanata/macbook.kbd`.
- The Mac has network access to download the VirtualHID package from GitHub.

## Install or Update

From this directory, run:

```sh
./install.sh
```

The script includes the VirtualHID installation from step 2 of Kanata's macOS
setup. It:

- Generates the installed Kanata plist from the active user's `$HOME`. Set
  `KANATA_CONFIG` to override the config path.
- Selects VirtualHID 6.2.0 for Kanata versions before 1.13.0.
- Selects VirtualHID 8.0.0 for Kanata 1.13.0 and newer.
- Downloads the release package only when the compatible version is absent.
- Verifies the pinned SHA-256 checksum and macOS package signature.
- Installs the package and runs the VirtualHID manager's `forceActivate`.
- Registers Kanata for macOS Accessibility permission.
- Installs root-owned plist copies under `/Library/LaunchDaemons`.
- Reloads both services in dependency order.
- Verifies both services remain running after startup. If Kanata exits because
  a privacy permission is missing, it opens both relevant System Settings
  panes and prints the binary path to approve.

macOS does not allow scripts to approve system extensions. If approval is
needed, the installer stops with instructions. Enable
`org.pqrs.Karabiner-DriverKit-VirtualHIDDevice` under
`System Settings > General > Login Items & Extensions > Driver Extensions`,
reboot if requested, then rerun `./install.sh`.

Kanata also requires both Input Monitoring and Accessibility permission for
`/opt/homebrew/bin/kanata`. Add and enable that binary under both:

- `System Settings > Privacy & Security > Input Monitoring`
- `System Settings > Privacy & Security > Accessibility`

After changing either permission, rerun `./install.sh`.

Without Accessibility permission, launchd repeatedly reports `last exit code =
1` even when Input Monitoring and VirtualHID are already enabled. Register the
binary and open the Accessibility pane with:

```sh
/opt/homebrew/bin/kanata --macos-request-permissions || true
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

If Kanata does not appear automatically, use the `+` button, press
`Command-Shift-G`, and select `/opt/homebrew/bin/kanata`. Use the same manual
path selection under Input Monitoring when necessary.

The installer is safe to rerun after approving the extension or changing a
plist.

Verify the jobs manually with:

```sh
sudo launchctl print system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl print system/dev.kanata.kanata
```

The healthy Kanata job reports `state = running`, a PID, and no prior exit.
Test an expected remapping after installation. The plists intentionally leave
stdout and stderr unconfigured during normal use; add temporary log paths only
while diagnosing startup failures.

## Reload Kanata

After changing only the Kanata keyboard config, restart Kanata without
reinstalling the plists:

```sh
sudo launchctl kickstart -k system/dev.kanata.kanata
```

## Uninstall

```sh
sudo launchctl bootout system/dev.kanata.kanata
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo rm /Library/LaunchDaemons/dev.kanata.kanata.plist
sudo rm /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
```
