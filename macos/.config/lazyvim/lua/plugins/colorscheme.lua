return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  -- Configure LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
