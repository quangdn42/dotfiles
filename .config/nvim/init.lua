-- [[ Setting options ]]
require 'config.options'
vim.g.python3_host_prog = '~/py3nvim/bin/python3'

-- [[ Install `lazy.nvim` plugin manager and bootstrap plugins]]
require 'config.lazy'

require 'config.autocmds'
require 'config.keymaps'
require 'config.lsp'

-- vim: ts=2 sts=2 sw=2 et
