return {
  {
    'mrjones2014/smart-splits.nvim',
    version = '*',
    event = 'VeryLazy',
    opts = {
      at_edge = 'stop',
    },
    -- stylua: ignore
    keys = { -- Move to Window using the <ctrl> hjkl keys
      { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'which_key_ignore' },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'which_key_ignore' },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'which_key_ignore' },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'which_key_ignore' },
      -- Resizing window
      { '<C-Left>', function() require('smart-splits').resize_left() end, desc = 'which_key_ignore' },
      { '<C-Down>', function() require('smart-splits').resize_down() end, desc = 'which_key_ignore' },
      { '<C-Up>', function() require('smart-splits').resize_up() end, desc = 'which_key_ignore' },
      { '<C-Right>', function() require('smart-splits').resize_right() end, desc = 'which_key_ignore' },
      -- Swapping buffers between windows
      { '<C-w>xh', function() require('smart-splits').swap_buf_left() end, desc = 'Left' },
      { '<C-w>xj', function() require('smart-splits').swap_buf_down() end, desc = 'Down' },
      { '<C-w>xk', function() require('smart-splits').swap_buf_up() end, desc = 'Up' },
      { '<C-w>xl', function() require('smart-splits').swap_buf_right() end, desc = 'Right' },
    },
  },
}
