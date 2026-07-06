-- LSP Plugins
return {
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    priority = 1000, -- needs to be loaded in first
    opts = {
      preset = 'classic',
      options = {
        show_source = { enabled = true, if_many = true },
        multilines = { enabled = true, always_show = true },
      },
    },
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- IncRename
      { 'smjonas/inc-rename.nvim', cmd = 'IncRename', opts = {} },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'stylua', 'shfmt' } },
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
  },
}
-- vim: ts=2 sts=2 sw=2 et
