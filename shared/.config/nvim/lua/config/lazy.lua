-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Preserve Neovim's native URI handler before plugins claim `gx`.
for _, mode in ipairs { 'n', 'x' } do
  local native_gx = vim.fn.maparg('gx', mode, false, true)
  if type(native_gx.callback) == 'function' then
    vim.keymap.set(mode, 'go', native_gx.callback, { desc = 'Open filepath or URI with system handler' })
  end
end

-- NOTE: Here is where you install your plugins.
require('lazy').setup {
  spec = {
    { import = 'plugins' },
    { import = 'plugins.lang' },
  },
  -- automatically check for plugin updates
  checker = { enabled = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        -- "matchit",
        -- "matchparen",
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
