return {
  {
    "stevearc/oil.nvim",
    opts = {
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["q"] = "actions.close",
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-h>"] = false,
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
    },
    keys = {
      { "-", "<CMD>Oil --float<CR>", desc = "Open parent directory" },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
