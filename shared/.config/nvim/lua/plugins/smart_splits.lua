return {
  {
    'mrjones2014/smart-splits.nvim',
    version = '*',
    lazy = false,
    opts = {
      at_edge = 'stop',
    },
    -- stylua: ignore
    keys = {
      -- Move between Neovim windows and Kitty panes.
      { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move to left pane' },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move to lower pane' },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move to upper pane' },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move to right pane' },
      -- Resize Neovim windows and Kitty panes.
      { '<C-Left>', function() require('smart-splits').resize_left() end, desc = 'Resize pane left' },
      { '<C-Down>', function() require('smart-splits').resize_down() end, desc = 'Resize pane down' },
      { '<C-Up>', function() require('smart-splits').resize_up() end, desc = 'Resize pane up' },
      { '<C-Right>', function() require('smart-splits').resize_right() end, desc = 'Resize pane right' },
      -- Swap buffers between Neovim windows.
      { '<C-w>xh', function() require('smart-splits').swap_buf_left() end, desc = 'Swap buffer left' },
      { '<C-w>xj', function() require('smart-splits').swap_buf_down() end, desc = 'Swap buffer down' },
      { '<C-w>xk', function() require('smart-splits').swap_buf_up() end, desc = 'Swap buffer up' },
      { '<C-w>xl', function() require('smart-splits').swap_buf_right() end, desc = 'Swap buffer right' },
    },
  },
}
