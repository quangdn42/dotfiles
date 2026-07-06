if vim.g.vscode then
  return
end
local wk = require("which-key")
if wk == true then
  return
end
wk.add({
  { "<leader>l", group = "language action" },
  { "<leader>le", "<cmd>GoIfErr<cr>", desc = "GoIfErr" },
  { "<leader>lt", group = "GoTag" },
  {
    "<leader>ltA",
    function()
      vim.api.nvim_feedkeys(":GoTagAdd ", "n", false)
    end,
    desc = "GoTagAdd prompt",
  },
  { "<leader>lta", "<cmd>GoTagAdd json<cr>", desc = "GoTagAdd json" },
  { "<leader>ltr", "<cmd>GoTagRm<cr>", desc = "GoTagRm" },
})
