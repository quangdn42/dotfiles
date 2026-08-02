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
    lazy = false,
    dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    opts = { PATH = 'append' },
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    config = function(_, opts)
      require('mason').setup(opts)

      local tools = {
        ['clangd'] = 'clangd',
        ['codelldb'] = 'codelldb',
        ['delve'] = 'dlv',
        ['gofumpt'] = 'gofumpt',
        ['goimports'] = 'goimports',
        ['gomodifytags'] = 'gomodifytags',
        ['gopls'] = 'gopls',
        ['impl'] = 'impl',
        ['lua-language-server'] = 'lua-language-server',
        ['basedpyright'] = 'basedpyright-langserver',
        ['marksman'] = 'marksman',
        ['ruff'] = 'ruff',
        ['shfmt'] = 'shfmt',
        ['sql-formatter'] = 'sql-formatter',
        ['stylua'] = 'stylua',
        ['tree-sitter-cli'] = 'tree-sitter',
        ['yaml-language-server'] = 'yaml-language-server',
        ['yamlfmt'] = 'yamlfmt',
        ['zls'] = 'zls',
      }
      local ensure_installed = {}
      for package, command in pairs(tools) do
        if vim.fn.executable(command) == 0 then
          ensure_installed[#ensure_installed + 1] = package
        end
      end
      table.sort(ensure_installed)

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
        run_on_start = true,
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
