-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, you can see `:help option-list`

local o = vim.o

-- Make line numbers default
o.number = true
-- You can also add relative line numbers, to help with jumping.
o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- Enable break indent
o.breakindent = true

-- Save undo history
o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
o.ignorecase = true
o.smartcase = true

-- Keep signcolumn on by default
o.signcolumn = 'yes'

-- Decrease update time - Save swap file and trigger CursorHold
o.updatetime = 200

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
o.timeoutlen = 300

-- Configure how new splits should be opened
o.splitright = true
o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'` and eol = '↲'
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
o.inccommand = 'split'

-- Show which line your cursor is on
o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
o.scrolloff = 2
o.sidescrolloff = 8

-- Steal from LazyVim
-- opt.shortmess:append { W = true, I = true, c = true, C = true }
vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
o.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
o.shiftround = true -- Round indent
o.shiftwidth = 4 -- Size of an indent (in space)
o.tabstop = 4 -- Size of a tab character
o.termguicolors = true -- True color support
-- opt.wildmode = 'longest:full,full' -- Command-line completion mode
o.winwidth = 10 -- Minimum window width
o.winminwidth = 10 -- Minimum window width
o.confirm = true -- Confirm to save changes before exiting modified buffer

-- nvim-0.10
o.smoothscroll = true

-- vim: ts=2 sts=2 sw=2 et
