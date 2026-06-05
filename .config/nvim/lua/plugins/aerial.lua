return {
  {
    'stevearc/aerial.nvim',
    opts = {},
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      {
        '<leader>ss',
        function()
          require('aerial').snacks_picker { layout = { preset = 'vscode', preview = 'main', hidden = {} } }
        end,
        desc = 'Buffer Symbols (Aerial)',
      },
    },
  },
}
