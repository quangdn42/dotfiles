# Software Manifest

This is a package reference, not an execution guide. Start with
[`manual.md`](manual.md).

Homebrew is the preferred installer. The Mac App Store is a fallback only when
there is no maintained Homebrew cask. Vendor installation is reserved for an
application unavailable through either source.

The declarations are split so the base install can run before App Store login:

- [`../../Brewfile`](../../Brewfile): taps, formulae, fonts, and casks.
- [`../../Brewfile.mas`](../../Brewfile.mas): App Store-only fallback apps.

## Tool Ownership

| Owner | Responsibility |
| --- | --- |
| Homebrew | Native CLI tools, backup tools, fonts, and macOS applications |
| mas | Selected App Store-only applications |
| mise | Global Python 3.12, Go 1.26, shared Go tools, and project runtimes |
| Mason | Missing system-tool fallbacks and editor-private debug adapters |
| Fisher | Fish plugins and Tide |
| lazy.nvim | Plugins for both Neovim configurations |

Avoid installing the same executable through multiple owners unless a project
has an explicit, documented version requirement.

## Homebrew Formulae

| Group | Formulae |
| --- | --- |
| Backup | `age`, `rclone`, `zstd` |
| Shell and navigation | `fish`, `fzf`, `lsd`, `zoxide` |
| Files and preview | `bat`, `fd`, `ffmpegthumbnailer`, `p7zip`, `poppler`, `ripgrep`, `unar`, `yazi` |
| Version control | `git`, `git-delta`, `gh`, `jj`, `lazygit` |
| Development utilities | `curlie`, `hurl`, `hyperfine`, `jq`, `just`, `showkey`, `tokei`, `uv`, `wget` |
| Shared editor tooling | `lua-language-server`, `marksman`, `pyright`, `ruff`, `shfmt`, `sql-formatter`, `stylua`, `tree-sitter-cli`, `yaml-language-server`, `yamlfmt` |
| Editors and configuration | `neovim`, `stow` |
| Machine setup | `kanata`, `mas`, `mise` |
| Coding agents | `anomalyco/tap/opencode` |

`p7zip`, `poppler`, `ffmpegthumbnailer`, and `unar` are retained for Yazi
preview and archive workflows rather than installed as incidental dependencies.

## Homebrew Casks

| Category | Casks |
| --- | --- |
| Terminals and development | `codex`, `ghostty`, `visual-studio-code`, `zed` |
| Browsers | `arc`, `firefox`, `google-chrome` |
| Communication | `discord`, `whatsapp`, `zalo`, `zoom` |
| Security and sync | `bitwarden`, `google-drive`, `tailscale-app` |
| Workflow | `appcleaner`, `flashspace`, `gonhanh`, `lunar`, `mac-mouse-fix`, `raycast`, `shottr`, `swish` |
| Media and creative | `gimp`, `iina`, `obs`, `spotify`, `steam` |
| Fonts | `font-ibm-plex-mono`, `font-jetbrains-mono-nerd-font` |

Bitwarden, Lunar, and WhatsApp deliberately use Homebrew even though App Store
versions exist.

## App Store Fallback

| Application | App Store ID |
| --- | ---: |
| Gifski | `1351639930` |
| Magic Battery | `1240063289` |
| uBlock Origin Lite | `6745342698` |
| Velja | `1607635845` |
| Vimari | `1480933944` |

Sign in to the App Store manually before applying `Brewfile.mas`.

## Vendor Installation

TinkerTool has no current Homebrew cask. Install it manually from the vendor
only after validating the download source. Do not add an untrusted tap merely
to automate one application.

## Intentionally Not Installed

- WezTerm and Kitty
- AeroSpace, Amethyst, Hammerspoon, SketchyBar, and borders
- Karabiner-Elements
- Helix and Firenvim
- Microsoft Office, GCal, and Google Docs/Sheets/Slides wrappers
- Microsoft Edge, Brave, and Antigravity
- DBeaver, PostgreSQL, Apache httpd, minikube, and OrbStack
- QMK Toolbox, avrdude, cross-compilers, and related taps
- Java and a globally selected Node.js development runtime; Homebrew Node.js
  may be installed as a dependency of shared editor tools
- nvm
- `spotify_player`
- aerc, isync, notmuch, msmtp, and rbw during the initial restore
- Starship

Their absence from `Brewfile` is intentional. Historical configuration files
may remain in the repository.

## Install Phases

1. Install Homebrew itself.
2. Apply the base `Brewfile`.
3. Sign in to the App Store.
4. Apply `Brewfile.mas`.
5. Install TinkerTool from its verified vendor source if still needed.
6. Complete application logins, licensing, and macOS privacy approvals.

The future bootstrap must be idempotent and must not call `brew cleanup` on the
old system as part of backup preparation.
