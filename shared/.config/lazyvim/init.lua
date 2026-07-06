-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- NOTE: create a virtual env at this path and install pynvim there
-- https://neovim.io/doc/user/provider.html#_python-integration
vim.g.python3_host_prog = "~/py3nvim/bin/python"
