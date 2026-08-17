-- Change the default Omarchy look'n'feel.
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config {
  general = {
    gaps_in = 3,
    gaps_out = 6,
    border_size = 3,
  },
  decoration = {
    rounding = 6,
    rounding_power = 3,
  },

  group = {
    groupbar = {
      font_size = 18,
      height = 33,
    },
  },

  scrolling = {
    explicit_column_widths = '0.32, 0.49, 0.65, 0.97',
  },

  --     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
  --     dim_inactive = true,
  --     dim_strength = 0.15,
}

-- Keep the Bitwarden desktop app tiled while preserving Omarchy's privacy rule.
-- This user rule is loaded after Omarchy's default app rules.
o.window('^(Bitwarden)$', { tag = '-floating-window' })

-- DPMS temporarily moves a disconnected display to Hyprland's FALLBACK
-- monitor. When the display returns, restore the workspace and window that
-- Hyprland remembered before that hand-off. This keeps unlock on the workspace
-- that was active when the screen was locked.
local function restore_focus_after_dpms(target_workspace, target_window)
  if not target_workspace then
    return
  end

  -- Focusing the same workspace is a no-op after the FALLBACK hand-off, so
  -- focus another normal workspace first, then restore the remembered one.
  for _, workspace in ipairs(hl.get_workspaces()) do
    if workspace.id ~= target_workspace.id and not workspace.name:match '^special:' then
      hl.dispatch(hl.dsp.focus { workspace = workspace })
      break
    end
  end

  hl.dispatch(hl.dsp.focus { workspace = target_workspace })
  if target_window then
    hl.dispatch(hl.dsp.focus { window = target_window })
  end
end

hl.on('monitor.added', function(monitor)
  -- Ignore ordinary hot-plug events; this is specifically the return from
  -- Hyprland's temporary FALLBACK monitor used during DPMS blanking.
  if monitor.name == 'FALLBACK' or not hl.get_monitor 'FALLBACK' then
    return
  end

  local target_workspace = hl.get_last_workspace()
  local target_window = hl.get_last_window()
  hl.timer(function()
    restore_focus_after_dpms(target_workspace, target_window)
  end, { timeout = 500, type = 'oneshot' })
end)

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- vim: ts=2 sts=2 sw=2 et
