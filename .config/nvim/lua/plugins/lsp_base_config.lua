-- LSP Plugins
return {
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
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', opts = {} }, -- NOTE: Must be loaded before dependants
      'mason-org/mason-lspconfig.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- IncRename
      { 'smjonas/inc-rename.nvim', cmd = 'IncRename', opts = {} },
    },
    config = function(_, opts)
      local function augroup(name)
        return vim.api.nvim_create_augroup('my-' .. name, { clear = true })
      end
      vim.api.nvim_create_autocmd('LspAttach', {
        group = augroup 'lsp-attach',
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          -- stylua: ignore start
          map('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition') --  To jump back, press <C-t>.
          map('gI', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
          map('gy', function() Snacks.picker.lsp_type_definitions() end, 'Goto Type Definition')
          map('<leader>ss', function() Snacks.picker.lsp_symbols() end, 'Document Symbols')
          map('<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, 'Workspace Symbols')
          vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, { desc = 'Goto References', nowait = true })
          -- stylua: ignore end
          vim.keymap.set('n', '<leader>cr', function()
            local inc_rename = require 'inc_rename'
            return ':' .. inc_rename.config.cmd_name .. ' ' .. vim.fn.expand '<cword>'
          end, { expr = true, desc = 'Rename Symbol (inc-rename)' })
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>cd', function()
            return require('flash').jump {
              matcher = function(win)
                ---@param diag vim.Diagnostic
                return vim.tbl_map(function(diag)
                  return {
                    pos = { diag.lnum + 1, diag.col },
                    end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                  }
                end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
              end,
              action = function(match, state)
                vim.api.nvim_win_call(match.win, function()
                  vim.api.nvim_win_set_cursor(match.win, match.pos)
                  vim.diagnostic.open_float()
                end)
                state:restore()
              end,
            }
          end, 'View Diagnostics')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('gK', vim.lsp.buf.signature_help, 'Signature Help')
          map('<c-k>', vim.lsp.buf.signature_help, 'Signature Help', 'i')

          map('<leader>cl', ':LspInfo<cr>', 'Lsp Info')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Toggle Inlay hints
          if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>uh', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end

          -- Language specifics that need to be called on LspAttach
          if opts.setup[client.name] then
            opts.setup[client.name](client)
          end
        end,
      })

      -- Change diagnostic symbols in the sign column (gutter)
      local signs = { ERROR = ' ', WARN = ' ', HINT = ' ', INFO = ' ' }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config {
        signs = { text = diagnostic_signs },
        float = { source = true, border = 'rounded' },
        virtual_text = true,
      }

      -- Enable the following language servers
      local servers = opts.servers or {}
      servers.lua_ls = {
        -- https://luals.github.io/wiki/settings/
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- Ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      }

      -- Configure lsp servers
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
      end

      -- Make sure they're installed
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
      }
    end,
  },

  {
    'mason-org/mason-lspconfig.nvim',
    event = 'LspAttach',
    opts = {},
    dependencies = {
      {
        'mason-org/mason.nvim',
        opts = { ensure_installed = { 'stylua', 'shfmt' } },
        keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
      },
      'neovim/nvim-lspconfig',
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
