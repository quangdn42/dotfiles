if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end
local find_files_with_hidden = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  LazyVim.pick("find_files", { hidden = true, default_text = line })()
end
return {
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
          horizontal = {
            preview_width = 0.6,
          },
        },
        mappings = {
          i = {
            ["<a-.>"] = find_files_with_hidden,
            ["<esc>"] = require("telescope.actions").close,
          },
        },
      },
    },
    keys = {
      { "<leader>f", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>F", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume" },
      -- { "<leader><space>", false },
      { "<leader>fb", false },
      { "<leader>fc", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>fg", false },
      { "<leader>fr", false },
      { "<leader>fR", false },
      -- { "<leader><space>g", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
      -- { "<leader><space>r", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      -- { "<leader><space>R", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    },
  },
}
