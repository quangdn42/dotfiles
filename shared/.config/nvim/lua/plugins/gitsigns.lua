return {
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Next git change' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Previous git change' })

        -- Actions
        map('n', '<leader>gp', gitsigns.preview_hunk_inline, { desc = 'Git Preview Hunk' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = 'Git Diff Against Index' })
        map('n', '<leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git Diff Against Last Commit' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Git Reset Hunk' })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'Git Reset Buffer' })
        -- Toggles
        map('n', '<leader>uB', gitsigns.toggle_current_line_blame, { desc = 'Toggle Blame Line' })
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
