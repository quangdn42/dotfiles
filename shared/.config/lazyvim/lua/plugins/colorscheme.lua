return {

  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = false,
      on_highlights = function(hl, colors)
        hl.MiniFilesTitleFocused = {
          bg = colors.yellow,
          fg = colors.black,
        }
        -- hl.InclineNormal = { bg = colors.yellow, fg = colors.black }
        -- hl.InclineNormalNC = { fg = colors.yellow, bg = colors.black }
        hl.InclineNormal = { fg = colors.yellow, bg = colors.black }
      end,
    },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      compile = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Flash
          FlashLabel = { bg = colors.palette.samuraiRed },
          -- Dark completion menu
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
    },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      custom_highlights = function(colors)
        return {
          FlashLabel = { fg = colors.crust, bg = colors.red, style = { "bold" } },
          -- FlashLabel = { fg = colors.red },
          FlashMatch = { fg = colors.text, bg = "#355868" },
          FlashCurrent = { fg = colors.crust, bg = colors.sky },
          -- InclineNormal = { bg = colors.rosewater, fg = colors.crust },
          InclineNormal = { fg = colors.peach, bg = colors.crust },
          CmpItemAbbrMatch = { fg = colors.blue },
          CmpItemAbbr = { fg = colors.text },
          PmenuBorder = { bg = colors.text },
        }
      end,
      -- color_overrides = {
      --   mocha = {
      --     base = "#111111",
      --     mantle = "#000000",
      --     crust = "#000000",
      --   },
      -- },
    },
  },

  -- Configure LazyVim to load colorscheme
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "catppuccin",
  --   },
  -- },
}
