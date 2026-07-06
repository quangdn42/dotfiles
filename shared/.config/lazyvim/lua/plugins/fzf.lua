return {
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = function()
      local actions = require("fzf-lua.actions")
      return {
        files = {
          cwd_prompt = false,
          actions = {
            ["alt-."] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ["alt-."] = { actions.toggle_hidden },
          },
        },
      }
    end,
    keys = {
      { "<leader>f", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>F", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      -- disable built-in
      { "<leader>fb", false },
      { "<leader>fc", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>fg", false },
      { "<leader>fr", false },
      { "<leader>fR", false },
    },
  },
}
