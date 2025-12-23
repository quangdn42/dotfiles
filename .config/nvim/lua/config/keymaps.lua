-- [[ Basic Keymaps ]]
local map = vim.keymap.set

-- Yank
map('n', 'Y', 'y$', { desc = 'Yank Till End Of Line' })
-- Redo
map('n', 'U', '<C-R>', { desc = 'Redo Last Change' })
-- Visual mode copy paste
map('v', 'C', '"_c', { desc = 'Change Without Yank' })
map('v', 'D', '"_d', { desc = 'Delete Without Yank' })
-- remap gx
map({ 'n', 'x' }, 'go', 'gx', { desc = 'Open filepath or URI under cursor with system handler' })

-- Move screen
-- map('n', '<C-Y>', function()
--   require('neoscroll').scroll(-5, { move_cursor = false, duration = 250 })
-- end, { desc = 'which_key_ignore' })
-- map('n', '<C-E>', function()
--   require('neoscroll').scroll(5, { move_cursor = false, duration = 250 })
-- end, { desc = 'which_key_ignore' })
map('n', '<c-y>', '5<c-y>', { desc = 'which_key_ignore' })
map('n', '<c-e>', '5<c-e>', { desc = 'which_key_ignore' })

-- Buffers
map('n', '<leader>[', '<c-^>', { desc = 'which_key_ignore' })
map('n', '<leader>`', '<c-^>', { desc = 'which_key_ignore' })

-- IDE like keymaps
map({ 'n', 'x' }, '<d-/>', '<cmd>norm gcc<cr>', { desc = 'Toggle Commenting' })
map('n', '<d-s>', '<cmd>w<cr>', { desc = 'Write File' }) -- for some reason 's' works but 'S' won't??

-- Tabs
map('n', ']<tab>', '<cmd>tabnext<cr>', { desc = 'Next tab' })
map('n', '[<tab>', '<cmd>tabprevious<cr>', { desc = 'Previous tab' })

-- Builtin Terminal
map('t', '<Esc><Esc>', '<c-\\><c-n>', { desc = 'Exit terminal mode' })

-- For qwerty or laptop
map({ 'n', 'x', 'o' }, 'gh', '^')
map({ 'n', 'x', 'o' }, 'gl', '$')

-- [[ Yoinked from LazyVim ]]

-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and Clear hlsearch' })

-- Add undo break-points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- highlights under cursor
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', '<cmd>InspectTree<cr>', { desc = 'Inspect Tree' })

-- windows
map('n', '<leader>-', '<c-w>s', { desc = 'Split Window Below' })
map('n', '<leader>|', '<c-w>v', { desc = 'which_key_ignore' })
map('n', '<leader>\\', '<c-w>v', { desc = 'Split Window Right' })

map('n', '<leader>wp', '<c-w>v<cmd>enew<cr><c-w>xl', { desc = 'Add Window Pad' })

-- vim: ts=2 sts=2 sw=2 et
