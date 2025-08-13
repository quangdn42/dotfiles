return {
  'andrewferrier/debugprint.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = {
    'folke/snacks.nvim', -- to use the `:Debugprint search` command with snacks.nvim
  },
  opts = {
    highlight_lines = false,
    keymaps = {
      normal = {
        plain_below = '<leader>dp',
        plain_above = '<leader>dP',
        variable_below = '<leader>dv',
        variable_above = '<leader>dV',
        variable_below_alwaysprompt = '',
        variable_above_alwaysprompt = '',
        surround_plain = '<leader>dsp',
        surround_variable = '<leader>dsv',
        surround_variable_alwaysprompt = '',
        textobj_below = '<leader>do',
        textobj_above = '<leader>dO',
        textobj_surround = '<leader>dso',
        toggle_comment_debug_prints = '<leader>dC',
        delete_debug_prints = '<leader>dc',
      },
      insert = {
        plain = '<C-G>p',
        variable = '<C-G>v',
      },
      visual = {
        variable_below = '<leader>dv',
        variable_above = '<leader>dV',
      },
    },
  },
}
