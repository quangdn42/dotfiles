#!/bin/sh

set -eu

if [ "$(uname -s)" != "Darwin" ]; then
    printf '%s\n' "This installer only supports macOS." >&2
    exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
destination_dir=/Library/LaunchDaemons

kanata_label=dev.kanata.kanata
vhid_label=org.pqrs.Karabiner-VirtualHIDDevice-Daemon

kanata_source="$script_dir/$kanata_label.plist"
vhid_source="$script_dir/$vhid_label.plist"
kanata_destination="$destination_dir/$kanata_label.plist"
vhid_destination="$destination_dir/$vhid_label.plist"

kanata_binary=/opt/homebrew/bin/kanata
kanata_config=/Users/quang-dang/.config/kanata/macbook.kbd
vhid_binary='/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'
vhid_info='/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/Info.plist'
vhid_manager='/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager'
vhid_extension_info='/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/Library/SystemExtensions/org.pqrs.Karabiner-DriverKit-VirtualHIDDevice.dext/Info.plist'
vhid_extension_id=org.pqrs.Karabiner-DriverKit-VirtualHIDDevice

package_path=

fail() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

bootout_if_loaded() {
    label=$1

    if sudo launchctl print "system/$label" >/dev/null 2>&1; then
        sudo launchctl bootout "system/$label"
    fi
}

cleanup() {
    if [ -n "$package_path" ]; then
        rm -f "$package_path"
    fi
}

install_vhid() {
    package_path=$(mktemp /tmp/kanata-vhid.XXXXXX)

    printf 'Downloading VirtualHID %s...\n' "$vhid_version"
    curl --fail --location --show-error \
        --proto '=https' \
        --tlsv1.2 \
        --output "$package_path" \
        "$vhid_url"

    actual_sha256=$(shasum -a 256 "$package_path")
    actual_sha256=${actual_sha256%% *}
    [ "$actual_sha256" = "$vhid_sha256" ] || fail "VirtualHID package checksum does not match"
    pkgutil --check-signature "$package_path" >/dev/null || fail "VirtualHID package signature is invalid"

    # Avoid replacing files beneath running processes during a driver upgrade.
    bootout_if_loaded "$kanata_label"
    bootout_if_loaded "$vhid_label"
    sudo installer -pkg "$package_path" -target /

    rm -f "$package_path"
    package_path=
}

trap cleanup 0
trap 'exit 1' HUP INT TERM

[ -d "$destination_dir" ] || fail "$destination_dir does not exist"
[ -x "$kanata_binary" ] || fail "Kanata is not executable at $kanata_binary"
[ -r "$kanata_config" ] || fail "Kanata config is not readable at $kanata_config"

plutil -lint "$kanata_source" >/dev/null
plutil -lint "$vhid_source" >/dev/null

kanata_version=$("$kanata_binary" --version)
kanata_version=${kanata_version##* }
kanata_version=${kanata_version#v}
kanata_major=${kanata_version%%.*}
kanata_remainder=${kanata_version#*.}
[ "$kanata_remainder" != "$kanata_version" ] || fail "Cannot parse Kanata version: $kanata_version"
kanata_minor=${kanata_remainder%%.*}

case "$kanata_major" in
    ''|*[!0-9]*) fail "Cannot parse Kanata version: $kanata_version" ;;
esac

case "$kanata_minor" in
    ''|*[!0-9]*) fail "Cannot parse Kanata version: $kanata_version" ;;
esac

if [ "$kanata_major" -gt 1 ] || { [ "$kanata_major" -eq 1 ] && [ "$kanata_minor" -ge 13 ]; }; then
    vhid_version=8.0.0
    vhid_sha256=0d412ea49613b70a981d816461dc3019b84a9659fde0a156939697283a61a7ac
else
    vhid_version=6.2.0
    vhid_sha256=9e8c46239f0748161241e42444857901224e5c82f5b58a1731df4c70bf0736a8
fi

vhid_url="https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v$vhid_version/Karabiner-DriverKit-VirtualHIDDevice-$vhid_version.pkg"
installed_vhid_version=
if [ -r "$vhid_info" ]; then
    installed_vhid_version=$(plutil -extract CFBundleShortVersionString raw -o - "$vhid_info" 2>/dev/null || :)
fi

sudo -v

if [ "$installed_vhid_version" != "$vhid_version" ] || [ ! -x "$vhid_binary" ] || [ ! -x "$vhid_manager" ]; then
    install_vhid
else
    printf 'VirtualHID %s is already installed.\n' "$vhid_version"
fi

[ -x "$vhid_manager" ] || fail "VirtualHID manager was not installed at $vhid_manager"

if ! sudo "$vhid_manager" forceActivate; then
    printf '%s\n' "VirtualHID activation did not complete; checking extension status." >&2
fi

[ -r "$vhid_extension_info" ] || fail "VirtualHID extension metadata was not installed"
vhid_extension_version=$(plutil -extract CFBundleShortVersionString raw -o - "$vhid_extension_info")

if ! systemextensionsctl list 2>/dev/null \
    | grep -F "$vhid_extension_id ($vhid_extension_version/" \
    | grep -Fq '[activated enabled]'; then
    printf '%s\n' \
        "VirtualHID $vhid_version is installed, but its system extension is not active." \
        "Enable $vhid_extension_id in:" \
        "System Settings > General > Login Items & Extensions > Driver Extensions" \
        "A reboot may be required. Rerun this installer after approval." >&2
    exit 1
fi

[ -x "$vhid_binary" ] || fail "VirtualHID daemon is not executable at $vhid_binary"

# Copy instead of symlinking so privileged launchd definitions are root-owned.
sudo install -o root -g wheel -m 0644 "$kanata_source" "$kanata_destination"
sudo install -o root -g wheel -m 0644 "$vhid_source" "$vhid_destination"

# Stop dependents first, then start the dependency first.
bootout_if_loaded "$kanata_label"
bootout_if_loaded "$vhid_label"
sudo launchctl bootstrap system "$vhid_destination"
sudo launchctl bootstrap system "$kanata_destination"

sudo launchctl print "system/$vhid_label" >/dev/null
sudo launchctl print "system/$kanata_label" >/dev/null

printf '%s\n' "Installed and loaded $vhid_label and $kanata_label."
