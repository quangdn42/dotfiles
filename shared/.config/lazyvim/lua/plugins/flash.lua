return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        char = {
          jump_labels = false,
          highlight = { backdrop = false },
          config = function(opts)
            opts.jump_labels = opts.jump_labels
              and vim.v.count == 0
              and vim.fn.reg_executing() == ""
              and vim.fn.reg_recording() == ""
              -- Show jump labels only when not in operator-pending mode
              and not vim.fn.mode(true):find("o")
          end,
        },
        search = {
          enabled = true,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, false },
      { "S", mode = { "n", "o", "x" }, false },
      { "<BS>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<S-BS>", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
}
