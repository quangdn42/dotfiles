return {
  {
    'stevearc/oil.nvim',
    opts = {
      -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
      -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
      default_file_explorer = true,
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['q'] = 'actions.close',
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-h>'] = false,
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
      float = {
        border = 'rounded',
      },
    },
    keys = {
      { '-', '<CMD>Oil --float<CR>', desc = 'Open parent directory' },
    },
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('lazy').load { plugins = { 'oil.nvim' } }
        end
      end
      if not require('lazy.core.config').plugins['oil.nvim']._.loaded then
        vim.api.nvim_create_autocmd('BufNew', {
          callback = function()
            if vim.fn.isdirectory(vim.fn.expand '<afile>') == 1 then
              require('lazy').load { plugins = { 'oil.nvim' } }
              -- Once oil is loaded, we can delete this autocmd
              return true
            end
          end,
        })
      end
    end,
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
