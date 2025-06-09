return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        zls = {
          enable_build_on_save = true,
          semantic_tokens = 'partial',
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        zig = { 'zigfmt' },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'zig' } },
  },
}
