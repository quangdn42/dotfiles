return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 5000,
      },
      statuscolumn = { enabled = true },
      styles = {
        lazygit = {
          width = 0.9999,
          height = 0.9999,
        },
      },
      dashboard = {
        preset = {
          header = [[
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = '<leader>f' },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = '󰦨 ', key = '/', desc = 'Live Grep', action = '<leader>/' },
            { icon = '󰷏 ', key = 'p', desc = 'Projects', action = '<leader>sp' },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = ' ', key = 'g', desc = 'LazyGit', action = '<leader>gg' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = '󰈆 ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        sections = {
          { section = 'header', hl = require('tokyonight.colors').setup().cyan },
          { section = 'keys', gap = 1, padding = 1 },
          { section = 'startup' },
        },
      },
    },
    -- stylua: ignore start
    keys = {
      { '<leader>cR', function() Snacks.rename.rename_file() end, desc = 'Rename File' },
      { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git Browse', mode = { 'n', 'v' } },
      { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Git Blame Line' },
      { '<leader>gf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit Current File History' },
      { '<leader>gg', function() Snacks.lazygit({ cwd = vim.fs.root(0, '.git')}) end, desc = 'Lazygit' },
      { '<leader>gs', function() Snacks.lazygit({ cwd = vim.fs.root(0, '.git')}) end, desc = 'Lazygit' },
      { '<leader>gl', function() Snacks.lazygit.log() end, desc = 'Lazygit Log (cwd)' },
      { '<leader>n', function() Snacks.scratch { icon = ' ', name = 'Todo', ft = 'markdown', file = '~/dotfiles/TODO.md' } end, desc = 'Notes' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
    },
    -- stylua: ignore end
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
          Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
          Snacks.toggle.diagnostics():map '<leader>ud'
          Snacks.toggle.inlay_hints():map '<leader>uh'
          Snacks.toggle.line_number():map '<leader>ul'
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
          Snacks.toggle.treesitter():map '<leader>uT'
          Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
          Snacks.toggle.zoom():map '<leader>uZ'
          Snacks.toggle.zen():map '<leader>uz'
          Snacks.toggle
            .new({
              id = 'format_buffer',
              name = 'Buffer Autoformat',
              get = function()
                return (vim.b.disable_autoformat == nil) and false or not vim.b.disable_autoformat
              end,
              set = function(state)
                vim.b.disable_autoformat = not state
              end,
            })
            :map '<leader>uF'
          Snacks.toggle
            .new({
              id = 'format_global',
              name = 'Global Autoformat',
              get = function()
                return (vim.g.disable_autoformat == nil) and false or not vim.g.disable_autoformat
              end,
              set = function(state)
                vim.g.disable_autoformat = not state
              end,
            })
            :map '<leader>uf'
        end,
      })
    end,
  },
}
