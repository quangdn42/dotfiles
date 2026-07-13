local fallback = {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}

local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(theme_file) ~= 1 then
  return fallback
end

local chunk, load_err = loadfile(theme_file)
if not chunk then
  vim.notify(("Failed to load Omarchy theme: %s"):format(load_err), vim.log.levels.WARN)
  return fallback
end

local ok, specs = pcall(chunk)
if not ok or type(specs) ~= "table" then
  vim.notify("Failed to evaluate Omarchy theme", vim.log.levels.WARN)
  return fallback
end

return specs
