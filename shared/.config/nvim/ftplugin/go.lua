vim.keymap.set('n', '<leader>ci', function()
  require('go-impl').open()
end, { buffer = true, desc = 'Go Impl' })
