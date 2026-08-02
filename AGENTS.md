# Repository Guidance

## Reinstall Work

- For macOS reinstall, backup, migration, or restore work, read
  `reinstall/macos/handoff.json` first. Use its router to inspect runtime state,
  then follow the script's exact next action; do not infer live state from
  unchecked Markdown checklist items or a restored agent conversation.
- Treat `reinstall/macos/config/archives.json` as the authoritative archive
  scope. Generated run plans and receipts are the evidence source of truth.
- The reinstall script must stop for human gates. Never pass an account,
  permission, erase, destructive-cleanup, or final-acceptance gate based only
  on agent inference.

## Custom Neovim

- Treat the custom Neovim configuration as the union of
  `shared/.config/nvim`, `macos/.config/nvim`, and `linux/.config/nvim`.
  GNU Stow merges the shared tree with the active platform tree under
  `~/.config/nvim`.
- Keep `shared/.config/lazyvim` out of custom-Neovim changes unless the task
  explicitly includes LazyVim.
- `shared/.config/nvim/lazy-lock.json` covers plugin specs from all three custom
  Neovim trees. Do not classify a lock entry as stale by inspecting only the
  shared tree or only the current platform's resolved Lazy spec.
- macOS declares Tokyonight in
  `macos/.config/nvim/lua/plugins/colorscheme.lua`. Linux declares the Omarchy
  theme set in `linux/.config/nvim/lua/plugins/all-themes.lua`; those theme lock
  entries are intentionally retained to avoid lockfile churn when themes
  change.
- Let the tracked lockfile pin plugin revisions. Avoid spec-level `commit`
  fields unless a deliberate permanent freeze is required. Keep `branch` or
  `version` constraints when they select an API generation or release series.
- Before pruning or regenerating the lockfile, audit plugin declarations across
  the shared, macOS, and Linux trees and verify both platform combinations.
