vim.diagnostic.config {
  signs = {
    text = {
      -- Change diagnostic symbols in the sign column (gutter)
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
    },
  },
  float = { source = true },
  virtual_text = false,
}

vim.lsp.enable {
  'lua_ls',
  'gopls',
  'marksman',
  'pyright',
  'ruff',
  'zls',
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
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

    map('<leader>cl', ':LspInfo<cr>', 'Lsp Info')

    -- Enable Inlay hints
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable()
    end
  end,
})
