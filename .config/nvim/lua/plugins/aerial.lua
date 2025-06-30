return {
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      {
        '<leader>ss',
        function()
          require('aerial').snacks_picker { layout = { preset = 'vscode', preview = 'main' } }
        end,
        mode = 'n',
        desc = 'Buffer Symbols (Treesitter)',
      },
    },
  },
}
