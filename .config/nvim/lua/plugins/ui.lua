local ui_events = { 'BufReadPre', 'BufNewFile' }
return {
  {
    'Bekaboo/dropbar.nvim',
    config = function()
      require('dropbar').setup()

      local dropbar_api = require 'dropbar.api'
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },

  -- Status line
  {
    'windwp/windline.nvim',
    config = function()
      require 'config.windline_airline'
    end,
  },

  -- Indent line
  {
    'lukas-reineke/indent-blankline.nvim',
    event = ui_events,
    main = 'ibl',
    opts = {
      scope = { enabled = false },
      indent = { char = '·', tab_char = '│' },
      -- indent = { char = '│', tab_char = '│' }, -- from lazyvim
    },
  },

  -- Auto resize focused splits
  {
    'nvim-focus/focus.nvim',
    event = ui_events,
    config = function()
      require('focus').setup {
        commands = true,
        ui = {
          cursorline = false,
          signcolumn = false,
        },
      }
      local ignore_filetypes = { 'snacks_picker', 'snacks_picker_list', 'dapui', 'neotest-summary' }
      local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

      local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })

      vim.api.nvim_create_autocmd('WinEnter', {
        group = augroup,
        callback = function(_)
          if vim.api.nvim_win_get_config(0).relative ~= '' or vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
            vim.w.focus_disable = true
          else
            vim.w.focus_disable = false
          end
        end,
        desc = 'Disable focus autoresize for BufType',
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        callback = function(_)
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.focus_disable = true
          else
            vim.b.focus_disable = false
          end
        end,
        desc = 'Disable focus autoresize for FileType',
      })
    end,
    keys = {
      { '<leader>uW', '<cmd>FocusToggle<cr>', desc = 'Toggle Window Focus' },
    },
  },

  -- smooth scrolling
  {
    'karb94/neoscroll.nvim',
    enabled = true,
    event = ui_events,
    opts = {
      duration_multiplier = 0.2,
    },
  },
}
