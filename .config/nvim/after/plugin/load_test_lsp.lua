-- local client = vim.lsp.start {
--   name = 'lsp-go',
--   cmd = { '/Users/quang-dang/Workspaces/lsp-go/bin/main' },
-- }

-- if not client then
--   vim.notify 'lsp-go server failed to start'
--   return
-- end

-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'markdown',
--   callback = function()
--     vim.lsp.buf_attach_client(0, client)
--   end,
-- })
