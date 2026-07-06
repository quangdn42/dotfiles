if vim.g.vscode then
  return
end
local wk = require("which-key")
if wk == true then
  return
end
wk.add({
  { "<leader>l", group = "language helpers" },
  { "<leader>lh", group = "hurl" },
  { "<leader>lhA", "<cmd>HurlToggleMode<cr>", desc = "Run All Requests in Verbose mode" },
  { "<leader>lhl", "<cmd>HurlShowLastResponse<cr>", desc = "Show Last Response" },
  { "<leader>lhm", "<cmd>HurlToggleMode<cr>", desc = "Hurl Toggle View Mode" },
  { "<leader>lhr", "<cmd>HurlRunnerAt<cr>", desc = "Run Request at Cursor" },
  {
    "<leader>lhs",
    function()
      vim.api.nvim_feedkeys(":HurlSetVariable ", "n", false)
    end,
    desc = "Set Variable",
  },
  { "<leader>lht", "<cmd>HurlRunnerToEntry<cr>", desc = "Run Requests to Cursor" },
  { "<leader>lhf", "<cmd>HurlRunnerToEnd<cr>", desc = "Run Requests From Cursor to End" },
  { "<leader>lhv", "<cmd>HurlManageVariable<cr>", desc = "Manage Variables" },
  { "<leader>lha", ":HurlRunner<cr>", desc = "Run All Requests", mode = { "n", "v" } },
})
