return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    version = '*',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
    opts = {
      transparent = false,
      on_highlights = function(hl, colors)
        hl['SnacksDashboardHeader'] = { fg = colors.blue2 }
        hl['WinBar'] = { bg = colors.bg }
        hl['WinBarNC'] = { bg = colors.bg }
        hl['ColorColumn'] = { bg = colors.red }
      end,
      on_colors = function(colors)
        colors.border = colors.blue2
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
