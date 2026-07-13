return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      transparent = false,
      on_highlights = function(hl, colors)
        hl.MiniFilesTitleFocused = {
          bg = colors.yellow,
          fg = colors.black,
        }
        hl.InclineNormal = { fg = colors.yellow, bg = colors.black }
      end,
    },
  },
  -- Configure LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
