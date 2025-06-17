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
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'zig' } },
  },
}
