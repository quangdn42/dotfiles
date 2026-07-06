return {
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    opts = { use_default_keymaps = false, max_join_length = 150 },
		-- stylua: ignore
    keys = {
      { 'gS', function() return require('treesj').split() end, desc = 'Split Treesitter Node' },
      { 'gJ', function() return require('treesj').join() end, desc = 'Join Treesitter Node' },
    },
  },
}
