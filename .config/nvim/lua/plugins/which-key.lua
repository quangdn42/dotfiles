return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      preset = 'helix',
      delay = 500,
      icons = {
        mappings = true,
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = 'code', mode = { 'n', 'x' } },
        { '<leader>d', group = 'debug', mode = { 'n', 'x' } },
        { '<leader>g', group = 'git', mode = { 'n', 'v' } },
        { '<leader>q', group = 'quit/session' },
        { '<leader>s', group = 'search' },
        { '<leader>t', group = 'toggle' },
        { '<leader>u', group = 'ui' },
        { '<leader>x', group = 'swap' },
        { '<leader>w', group = 'windows', proxy = '<c-w>' }, -- proxy to window mappings
        { '<C-W>x', group = 'swap' },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
