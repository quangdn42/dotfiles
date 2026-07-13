return {
  -- Keep all Omarchy theme plugins available on Linux so theme changes don't churn lazy-lock.json.
  { 'ribru17/bamboo.nvim', lazy = true, priority = 1000 },
  { 'bjarneo/aether.nvim', lazy = true, priority = 1000 },
  { 'bjarneo/ethereal.nvim', lazy = true, priority = 1000 },
  { 'bjarneo/hackerman.nvim', lazy = true, priority = 1000 },
  { 'bjarneo/vantablack.nvim', lazy = true, priority = 1000 },
  { 'bjarneo/white.nvim', lazy = true, priority = 1000 },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    priority = 1000,
    opts = {
      dim_inactive = { enabled = false },
      integration = {
        cmp = false,
        blink_cmp = true,
        diffview = true,
      },
      custom_highlights = function(colors)
        return {
          FlashLabel = { fg = colors.crust, bg = colors.red, style = { 'bold' } },
          FlashMatch = { fg = colors.text, bg = '#355868' },
          FlashCurrent = { fg = colors.crust, bg = colors.sky },
          InclineNormal = { fg = colors.peach, bg = colors.crust },
          CmpItemAbbrMatch = { fg = colors.blue },
          CmpItemAbbr = { fg = colors.text },
          PmenuBorder = { bg = colors.text },
        }
      end,
    },
  },
  { 'neanias/everforest-nvim', lazy = true, priority = 1000 },
  { 'kepano/flexoki-neovim', lazy = true, priority = 1000 },
  { 'ellisonleao/gruvbox.nvim', lazy = true, priority = 1000 },
  {
    'rebelot/kanagawa.nvim',
    lazy = true,
    priority = 1000,
    opts = {
      compile = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette
        return {
          FlashLabel = { fg = palette.lotusCyan, bg = palette.samuraiRed, bold = true },
          FlashMatch = { fg = palette.lotusCyan, bg = palette.lotusBlue4 },
          FlashCurrent = { fg = palette.sumiInk2, bg = palette.surimiOrange },
          EyelinerPrimary = { fg = palette.surimiOrange },
          EyelinerSecondary = { fg = palette.springBlue },
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend },
          PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
    },
  },
  { 'tahayvr/matteblack.nvim', lazy = true, priority = 1000 },
  { 'gthelding/monokai-pro.nvim', lazy = true, priority = 1000 },
  { 'EdenEast/nightfox.nvim', lazy = true, priority = 1000 },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true, priority = 1000 },
  {
    'folke/tokyonight.nvim',
    lazy = true,
    version = '*',
    priority = 1000,
    opts = {
      transparent = false,
      on_highlights = function(hl, colors)
        hl['SnacksDashboardHeader'] = { fg = colors.blue2 }
        hl['WinBar'] = { bg = colors.bg }
        hl['WinBarNC'] = { bg = colors.bg }
      end,
      on_colors = function(colors)
        colors.border = colors.blue2
      end,
    },
  },
  { 'OldJobobo/miasma.nvim', lazy = true, priority = 1000 },
  { 'OldJobobo/retro-82.nvim', lazy = true, priority = 1000 },
  { 'omacom-io/lumon.nvim', lazy = true, priority = 1000 },
}
-- vim: ts=2 sts=2 sw=2 et
