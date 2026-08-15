-- Shared Neovim profile for Kitty's ANSI scrollback buffer. Kitty keeps normal
-- plugin loading disabled; this profile only reuses the installed active theme.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

local keymaps = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua/config/keymaps.lua')
dofile(keymaps)

local o = vim.o
o.clipboard = 'unnamedplus'
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.mouse = 'a'
o.termguicolors = true
o.showmode = false

local function omarchy_theme()
  local path = vim.fn.expand '~/.config/omarchy/current/theme/neovim.lua'
  if vim.fn.filereadable(path) ~= 1 then
    return { 'folke/tokyonight.nvim' }, 'tokyonight-night'
  end

  local ok, specs = pcall(dofile, path)
  if not ok or type(specs) ~= 'table' then
    return nil, nil, specs
  end

  local theme
  local colorscheme
  for _, spec in ipairs(specs) do
    local source = type(spec) == 'table' and spec[1] or nil
    if source == 'LazyVim/LazyVim' and type(spec.opts) == 'table' then
      colorscheme = spec.opts.colorscheme
    elseif not theme and source then
      theme = spec
    end
  end

  return theme, colorscheme
end

local function load_theme(theme, colorscheme)
  if not theme or type(colorscheme) ~= 'string' then
    return false, 'active theme spec is incomplete'
  end

  local lazy_root = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy')
  local lazy_path = vim.fs.joinpath(lazy_root, 'lazy.nvim')
  if vim.fn.isdirectory(lazy_path) ~= 1 then
    return false, 'lazy.nvim is not installed'
  end

  -- --noplugin keeps the pager isolated. Enable plugin loading only while Lazy
  -- adds the selected theme, then restore the original setting.
  local loadplugins = o.loadplugins
  o.loadplugins = true
  local ok, err = pcall(function()
    vim.opt.runtimepath:prepend(lazy_path)
    require('lazy').setup({ theme }, {
      root = lazy_root,
      local_spec = false,
      install = { missing = false },
      pkg = { enabled = false },
      rocks = { enabled = false },
      checker = { enabled = false },
      change_detection = { enabled = false },
      readme = { enabled = false },
    })
  end)
  o.loadplugins = loadplugins

  if not ok then
    return false, err
  end
  return pcall(vim.cmd.colorscheme, colorscheme)
end

local function use_terminal_palette(err)
  vim.g.kitty_scrollback_theme_error = tostring(err)
  o.termguicolors = false
  pcall(vim.cmd.colorscheme, 'default')
end

local theme, colorscheme, theme_err = omarchy_theme()
local ok, err = load_theme(theme, colorscheme)
if not ok then
  use_terminal_palette(err or theme_err)
end

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('kitty-scrollback-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 }
  end,
})

vim.keymap.set('n', 'q', '<cmd>qa!<cr>', { silent = true, desc = 'Close scrollback' })
