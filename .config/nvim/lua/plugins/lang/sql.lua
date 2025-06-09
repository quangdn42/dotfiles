local sql_ft = { 'sql', 'mysql', 'plsql' }
return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'sql' } },
  },

  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      -- opts.formatters.sqlfluff = {
      --   args = { 'format', '-' },
      -- }
      for _, ft in ipairs(sql_ft) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'sqlfluff')
      end
    end,
  },

  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'sqlfluff' } },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.filetype.add {
        extension = { sqlfluff = 'toml' },
      }
    end,
  },
}
