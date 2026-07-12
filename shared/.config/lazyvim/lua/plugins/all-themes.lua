return {
  -- Keep all Omarchy theme plugins available so theme changes don't churn lazy-lock.json.
  { "ribru17/bamboo.nvim", lazy = true, priority = 1000 },
  { "bjarneo/aether.nvim", lazy = true, priority = 1000 },
  { "bjarneo/ethereal.nvim", lazy = true, priority = 1000 },
  { "bjarneo/hackerman.nvim", lazy = true, priority = 1000 },
  { "bjarneo/vantablack.nvim", lazy = true, priority = 1000 },
  { "bjarneo/white.nvim", lazy = true, priority = 1000 },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
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
  { "sainnhe/everforest", lazy = true, priority = 1000 },
  { "kepano/flexoki-neovim", lazy = true, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
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
  { "tahayvr/matteblack.nvim", lazy = true, priority = 1000 },
  { "loctvl842/monokai-pro.nvim", lazy = true, priority = 1000 },
  { "shaunsingh/nord.nvim", lazy = true, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 1000 },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
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
  { "OldJobobo/miasma.nvim", lazy = true, priority = 1000 },
  { "OldJobobo/retro-82.nvim", lazy = true, priority = 1000 },
  { "omacom-io/lumon.nvim", lazy = true, priority = 1000 },
}
