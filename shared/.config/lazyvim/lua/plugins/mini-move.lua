return {
  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = "<M-left>",
        right = "<M-right>",
        down = "<M-down>",
        up = "<M-up>",

        -- Move current line in Normal mode
        line_left = "<M-left>",
        line_right = "<M-right>",
        line_down = "<M-down>",
        line_up = "<M-up>",
      },
    },
    config = function(_, opts)
      vim.schedule(function()
        require("mini.move").setup(opts)
      end)
    end,
  },
}
