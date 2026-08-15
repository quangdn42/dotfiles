# Omarchy 4 Migration Groups

This is the authoritative one-time inventory for the Omarchy 4 migration. It
classifies desired outcomes rather than preserving old implementation details.
Work in order; test stock Omarchy 4 before porting anything.

`Leave alone` means do not detach, delete, or rewrite the item as part of the
desktop migration. `Remove` means remove the legacy path from the migration
branch after its live symlink is detached; it remains on
`archive/omarchy-3.8.4-pre-quattro`. `Port if needed` means rebuild only the
stated outcome using the v4 mechanism.

## 1. Display

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/hypr/monitors.conf` | Crisp, comfortable text and a usable physical size; legacy fallback is monitor scale `1` plus GTK scale `1`; start on workspace `11`. | **Test native v4 scaling first.** Do not create `monitors.lua` initially. If the native scale produces unacceptable fractional-scaling blur, port the exact legacy scale-`1`/GTK-`1` outcome to `~/.config/hypr/monitors.lua`; move the workspace-start behavior to the bindings/workspaces group. Do not copy `.conf` syntax. | Inspect terminal, GTK, Qt, Chromium, and Electron text at the normal working distance; reconnect after suspend. Accept native scaling only when rendering is crisp, otherwise record the blur and use the documented fallback. |

Display is a deliberate decision gate, not a preference comparison. First use
the new native v4 scale unchanged. Only blurry text or another objective
rendering failure justifies returning to the existing scale-`1` approach. The
result decides which branch the application-scaling group follows.

## 2. Input and session environment

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/hypr/autostart.conf`; `linux/.config/uwsm/env` | fcitx5-bamboo works; custom `mise` activation remains available. | **Port if needed.** Keep only the fcitx and mise behavior in v4-supported autostart/environment files. **Remove** the old `OMARCHY_PATH=$HOME/.local/share/omarchy` export: v4 owns that path and it is package-backed. | Input method works in a terminal, browser, and lock screen; a new login loads mise without errors. |

## 3. Application scaling

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/environment.d/dotfiles-scale.conf`; `linux/.config/chromium-flags.conf`; `linux/.config/electron-flags.conf`; old Walker size wrapper in `linux/.config/omarchy/extensions/menu.sh` | Steam/Qt/Electron/Chromium are readable without making the whole desktop oversized. | **Native-display result accepted:** leave all legacy app-scale overrides removed; use only v4 shell font/spacing controls for the shell. **Scale-`1` fallback selected:** rebuild the prior approach incrementally—`QT_SCALE_FACTOR=1.5`, Steam scaling `1.5`, then Chromium/Electron device-scale `1.5` only for applications that need it. Re-evaluate Chromium's legacy `~/.local/share/omarchy` extension path against v4's package layout; do not carry that path forward blindly. | Chromium, Electron, Qt, Steam, menu, notifications, and terminal all have usable scale with no blur or double-scaling. Record each retained factor and the app that requires it. |

## 4. Terminals

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/alacritty/alacritty.toml`; `linux/.config/ghostty/config`; `linux/.config/kitty/kitty.conf` and related Kitty files | Fonts, padding, clipboard keys, split/tab behavior, and dynamic theming remain comfortable. | **Port if needed.** Recreate only non-default terminal preferences. Replace legacy `~/.config/omarchy/current/theme/...` imports with v4 theme templates or state paths documented by v4. | Each installed terminal starts, receives theme updates, has correct font size, and its custom keybindings work. |

## 5. Hyprland bindings and workspaces

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/hypr/bindings.conf`; `linux/.config/hypr/bindings/tiling.conf`; `linux/.config/hypr/bindings/utilities.conf`; workspace-start line from `monitors.conf` | Familiar non-default navigation, persistent workspaces `11`–`15`, window grouping, and selected application bindings. | **Port if needed** to `~/.config/hypr/bindings.lua`. Keep v4 defaults when equivalent. Translate or drop commands tied to Walker, Waybar, Mako, or old shell helpers; map only needed outcomes to v4 shell commands. | `hyprctl configerrors` is clean; every retained binding works; default v4 bindings still work. |

## 6. Hyprland look and layout

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/hypr/looknfeel.conf` | Tight gaps, coherent rounded corners, readable group tabs at scale `1`, and selected scrolling-layout widths. | **Start with the first-party Solitude theme as the design reference.** Its v4 `hyprland.lua` uses `rounding = 6`, `rounding_power = 3`, a subtle active-border gradient, and matching group-border colors. Test that designed combination before porting any old values. If a different color theme is preferred but Solitude geometry is retained, port only `rounding = 6` and `rounding_power = 3` to `~/.config/hypr/looknfeel.lua`; leave colors and border gradients theme-owned. Port old gaps, border size, group-tab sizing, or scrolling widths only if the Solitude-informed stock behavior does not meet the outcome. | Test normal, grouped, tiled, and scrolling windows; switch themes to prove geometry remains coherent while colors remain theme-owned; then run `hyprctl configerrors`. |

Do not automatically restore the old `rounding = 10` or a fixed `border_size =
4`. Solitude's smaller radius and non-linear corner power are the intended v4
rounded-corner design, not merely an example value. The source reference is
[`themes/solitude/hyprland.lua`](https://github.com/basecamp/omarchy/blob/quattro/themes/solitude/hyprland.lua).

## 7. Idle, lock, and rbw

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/hypr/hypridle.conf` | Desktop locks and suspends reliably; rbw locks immediately when the desktop locks. | **Remove the file.** Set desired idle timing in v4 `~/.config/omarchy/shell.json`; do not restore Hypridle/Hyprlock. If stock v4 lacks a supported lock hook, add the smallest user-owned headless Shell service plugin under `~/.config/omarchy/plugins/` that observes the public `omarchy-shell lock isLocked` IPC and runs idempotent `rbw lock` once on each unlocked-to-locked transition. Never fork or edit Omarchy's built-in lock plugin. | Manual lock, idle lock, and suspend/resume work. Unlock rbw, trigger each lock path, and verify it becomes locked exactly once. |

Omarchy 4's built-in `omarchy-system-lock` already owns desktop locking and
Quickshell's lock screen. The custom behavior is only the rbw lock edge, not
SSH-agent or mail behavior.

## 8. Theme adapters

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/omarchy/hooks/theme-set.d/{bat,delta,fish}`; `linux/.config/fish/conf.d/theme.fish`; `linux/.config/fish/functions/__dotfiles_omarchy_fish_theme.fish`; `linux/.config/nvim/lua/{omarchy,plugins}` | Fish, bat, delta, terminals, and custom Neovim follow the selected Omarchy theme where that remains useful. | **Port if needed.** Replace reads from `~/.config/omarchy/current` with v4's state/template model. Prefer `~/.config/omarchy/themed/*.tpl` for theme-generated config and retain minimal hooks only for tools without a v4 template path. Touch custom Neovim only; do not modify `shared/.config/lazyvim` or `linux/.config/lazyvim`. | Change among dark and light themes; confirm Fish, bat, delta, terminals, and custom Neovim behave without stale-path errors. |

Custom Neovim is the union of `shared/.config/nvim` and `linux/.config/nvim`.
LazyVim is explicitly out of scope even where it has legacy Omarchy theme
references.

## 9. Shell UI and retired desktop components

| Current paths | Desired outcome | Disposition and v4 destination | Acceptance |
| --- | --- | --- | --- |
| `linux/.config/waybar/`; `linux/.config/walker/`; `linux/.config/mako/config`; `linux/.config/swayosd/style.css`; `linux/.config/omarchy/extensions/menu.sh` | A readable bar, launcher, notifications, OSD, and menu with the necessary personal actions. | **Remove; never restow directly.** First use stock Quickshell. If something material is missing, use `~/.config/omarchy/shell.json`, `~/.config/omarchy/extensions/omarchy-menu.jsonc`, shell theme tokens/templates, or a user plugin. Do not revive a parallel Waybar/Walker/Mako stack. | Shell IPC is healthy; bar, launcher, notifications, OSD, menu, and theme scale work without old processes/configs. |

## Explicitly outside the desktop migration

Leave these active and unchanged while turning off desktop overrides:

| Paths | Why they stay |
| --- | --- |
| `linux/.config/rbw/config.json`; `linux/.local/bin/rbw-pinentry` | rbw pinentry routing is independent of Omarchy's retired desktop components. |
| `shared/.local/bin/ssh-key-sync`; local `~/.ssh/id_ed25519` workflow | SSH uses a normal local key. rbw is only the explicit sync source, not the SSH agent. |
| `linux/.local/bin/mail-credential`; Linux mail-sync/vdirsyncer units; `shared/.config/aerc`, `isyncrc`, `msmtp`, and `vdirsyncer` files | Normal mail reads only the local Secret Service cache. rbw is contacted only by explicit `mail-credential refresh`. |

After the idle-lock group, prove this separation: `mail-credential status` and a
mail refresh still work while rbw is locked, and the local SSH key has correct
permissions and authenticates normally. Do not print credentials into terminal
logs or migration notes.

## Final negative checks

Before final acceptance, search active configuration for the retired component
names and old theme path. Any remaining result needs an explicit reason:

```sh
rg -n 'waybar|walker|mako|swayosd|hypridle|hyprlock|\.config/omarchy/current' \
  ~/.config
```

Also verify that no live configuration symlink still points at a legacy path in
the repository, that `hyprctl configerrors` is clean, and that no Omarchy-owned
file under `/usr/share/omarchy` was edited.
