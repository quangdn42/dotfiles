return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- Build
              directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
              -- Formatting
              gofumpt = true,
              -- UI
              codelenses = {
                vulncheck = true,
                test = true,
              },
              semanticTokens = true,
              -- Inlay hints
              hints = {
                -- assignVariableTypes = true,
                -- compositeLiteralFields = true,
                -- compositeLiteralTypes = true,
                constantValues = true,
                -- functionTypeParameters = true,
                -- parameterNames = true,
                rangeVariableTypes = true,
              },
              -- Diagnostics
              staticcheck = true,
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              -- Completion
              usePlaceholders = true,
            },
          },
        },
      },
      setup = {
        gopls = function(client)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          if not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
              range = true,
            }
          end
          -- end workaround
        end,
      },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'goimports', 'gofumpt', 'gomodifytags' },
    },
  },
  {
    'nvimtools/none-ls.nvim',
    ft = 'go',
    opts = function(_, opts)
      local nls = require 'null-ls'
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.gomodifytags,
      })
    end,
  },
  {
    'fang2hou/go-impl.nvim',
    ft = 'go',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    opts = {},
    keys = {
      {
        '<leader>ci',
        function()
          require('go-impl').open()
        end,
        mode = { 'n' },
        desc = 'Go Impl',
      },
    },
  },
}
