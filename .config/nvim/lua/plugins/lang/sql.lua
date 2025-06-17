return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'sql' } },
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
