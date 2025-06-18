vim.keymap.set('n', '<leader>ci', function()
  require('go-impl').open()
end, { desc = 'Go Impl' })
