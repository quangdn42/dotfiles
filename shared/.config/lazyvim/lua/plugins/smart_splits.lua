return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      at_edge = "stop",
    },
    keys = { -- Move to Window using the <ctrl> hjkl keys
      { "<C-h>", "<cmd>:lua require('smart-splits').move_cursor_left()<cr>", desc = "which_key_ignore" },
      { "<C-j>", "<cmd>:lua require('smart-splits').move_cursor_down()<cr>", desc = "which_key_ignore" },
      { "<C-k>", "<cmd>:lua require('smart-splits').move_cursor_up()<cr>", desc = "which_key_ignore" },
      { "<C-l>", "<cmd>:lua require('smart-splits').move_cursor_right()<cr>", desc = "which_key_ignore" },
      -- Resizing window
      { "<C-Left>", "<cmd>:lua require('smart-splits').resize_left()<cr>", desc = "which_key_ignore" },
      { "<C-Down>", "<cmd>:lua require('smart-splits').resize_down()<cr>", desc = "which_key_ignore" },
      { "<C-Up>", "<cmd>:lua require('smart-splits').resize_up()<cr>", desc = "which_key_ignore" },
      { "<C-Right>", "<cmd>:lua require('smart-splits').resize_right()<cr>", desc = "which_key_ignore" },
      -- swapping buffers between windows
      { "<C-w>xh", "<cmd>:lua require('smart-splits').swap_buf_left()<cr>", desc = "Left" },
      { "<C-w>xj", "<cmd>:lua require('smart-splits').swap_buf_down()<cr>", desc = "Down" },
      { "<C-w>xk", "<cmd>:lua require('smart-splits').swap_buf_up()<cr>", desc = "Up" },
      { "<C-w>xl", "<cmd>:lua require('smart-splits').swap_buf_right()<cr>", desc = "Right" },
    },
  },
}
