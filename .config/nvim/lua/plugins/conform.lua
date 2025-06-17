local formatters_by_ft = {
  go = { 'goimports', 'gofumpt' },
  hurl = { 'hurlfmt' },
  just = { 'just' },
  lua = { 'stylua' },
  mysql = { 'sqlfluff' },
  plsql = { 'sqlfluff' },
  python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
  sh = { 'shfmt' },
  sql = { 'sqlfluff' },
  zig = { 'zigfmt' },
}

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = 'Format',
      },
      {
        '<leader>cF',
        function()
          require('conform').format { formatters = { 'injected' }, timeout_ms = 3000 }
        end,
        mode = { 'n', 'v' },
        desc = 'Format Injected Langs',
      },
    },
    init = function()
      vim.api.nvim_create_user_command('FormatToggle', function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          if vim.b.disable_autoformat == nil or not vim.b.disable_autoformat then
            vim.b.disable_autoformat = true
            Snacks.notify 'Disable Autoformat Buffer'
          else
            vim.b.disable_autoformat = false
            Snacks.notify 'Enable Autoformat Buffer'
          end
        else
          if vim.g.disable_autoformat == nil or not vim.g.disable_autoformat then
            vim.g.disable_autoformat = true
            Snacks.notify 'Disable Autoformat Global'
          else
            vim.g.disable_autoformat = false
            Snacks.notify 'Enable Autoformat Global'
          end
        end
      end, {
        desc = 'Toggle autoformat-on-save',
        bang = true,
      })
      vim.keymap.set('n', '<leader>uf', '<cmd>FormatToggle<cr>', { desc = 'Toggle Autoformat Global' })
      vim.keymap.set('n', '<leader>uF', '<cmd>FormatToggle!<cr>', { desc = 'Toggle Autoformat Buffer' })
    end,
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        -- disable autoformat
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = formatters_by_ft,
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
