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
    explicit_column_widths = "0.32, 0.49, 0.65, 0.97",
  },

  --     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
  --     dim_inactive = true,
  --     dim_strength = 0.15,
}

-- Keep the Bitwarden desktop app tiled while preserving Omarchy's privacy rule.
-- This user rule is loaded after Omarchy's default app rules.
o.window("^(Bitwarden)$", { tag = "-floating-window" })

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
