local formatters_by_ft = {
  go = { 'goimports', 'gofumpt' },
  hurl = { 'hurlfmt' },
  just = { 'just' },
  lua = { 'stylua' },
  sql = { 'sql_formatter' },
  mysql = { 'sql_formatter' },
  plsql = { 'sql_formatter' },
  python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
  sh = { 'shfmt' },
  yaml = { 'yamlfmt' },
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
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- disable autoformat
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
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
