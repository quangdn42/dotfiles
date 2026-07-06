return {
  {
    "gbprod/yanky.nvim",
    event = "LazyFile",
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>p",
        function()
          if LazyVim.pick.picker.name == "telescope" then
            require("telescope").extensions.yank_history.yank_history({})
          else
            vim.cmd([[YankyRingHistory]])
          end
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
    },
  },

  -- allow paste to target a text object and replace it with content of register
  {
    "gbprod/substitute.nvim",
    opts = {
      highlight_substituted_text = { enabled = true, timer = 150 },
    },
    -- stylua: ignore
    keys = {
      { 'gp', function() require('substitute').operator() end, desc = 'Substitute' },
      { 'gpp', function() require('substitute').line() end, desc = 'Substitute Line' },
      { 'gp', function() require('substitute').visual() end, mode = { 'x' }, desc = 'Substitute' },
      { 'gb', function() require('substitute.exchange').operator() end, desc = 'which_key_ignore' },
      { 'gbb', function() require('substitute.exchange').line() end, desc = 'Exchange Line' },
      { 'gb', function() require('substitute.exchange').visual() end, mode = { 'x' }, desc = 'Exchange Selection' },
    },
  },
}
