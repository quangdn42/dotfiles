if true then
  return {}
end
local function ToggleCopilot()
  if vim.b.copilot_enabled == nil or vim.b.copilot_enabled == true then
    vim.b.copilot_enabled = false
    vim.notify("Copilot disabled for current buffer", vim.log.INFO)
  else
    vim.b.copilot_enabled = true
    vim.notify("Copilot enabled for current buffer", vim.log.INFO)
  end
end

local function GloballyToggleCopilot()
  if vim.g.copilot_enabled == nil or vim.g.copilot_enabled == true then
    vim.cmd.Copilot("disable")
    vim.cmd.Copilot("status")
    vim.g.copilot_enabled = false
  else
    vim.cmd.Copilot("enable")
    vim.cmd.Copilot("status")
    vim.g.copilot_enabled = true
  end
end

return {
  {
    "github/copilot.vim",
    event = "VimEnter",
    init = function()
      vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
      vim.g.copilot_enabled = true
    end,
    keys = {
      -- { "Tab", "copilot#Accept()", { expr = true, silent = true, mode = "i" } },
      {
        "<leader>at",
        function()
          return ToggleCopilot()
        end,
        desc = "Toggle Copilot Suggestion in Buffer",
      },
      {
        "<leader>ag",
        function()
          return GloballyToggleCopilot()
        end,
        desc = "Toggle Copilot Suggestion Globally",
      },
    },
  },
}
