local themes = {
  ibm_plex = {
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
    },
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      {
        icon = ' ',
        title = 'Git Status',
        section = 'terminal',
        enabled = function()
          return Snacks.git.get_root() ~= nil
        end,
        cmd = 'git status --short --branch --renames',
        height = 5,
        padding = 1,
        ttl = 5 * 60,
        indent = 3,
      },
      { section = 'startup' },
    },
  },
  default = {
    enabled = true,
    preset = {
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = '<leader>f' },
        { icon = ' ', key = '/', desc = 'Live Grep', action = '<leader>/' },
        { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
        { icon = ' ', key = 'g', desc = 'LazyGit', action = '<leader>gg' },
        { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      {
        pane = 2,
        icon = ' ',
        title = 'Git Status',
        section = 'terminal',
        enabled = function()
          return Snacks.git.get_root() ~= nil
        end,
        cmd = 'git status --short --branch --renames',
        height = 5,
        padding = 1,
        ttl = 5 * 60,
        indent = 3,
      },
      { section = 'startup' },
    },
  },
}

local function config_dashboard(theme)
  local config = themes[theme]
  local default = themes['default']
  if not config then
    return default
  end
  local out = vim.tbl_deep_extend('force', default, config)
  if theme == 'ibm_plex' then
    local colors = require('tokyonight.colors').setup()
    default['sections'][1]['hl'] = colors.cyan
  end
  return out
end

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
      dashboard = config_dashboard 'cascadia',
      styles = {
        lazygit = {
          width = 0.9999,
          height = 0.9999,
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
          Snacks.toggle.line_number():map '<leader>ul'
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
          Snacks.toggle.treesitter():map '<leader>uT'
          Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
          Snacks.toggle.zoom():map '<leader>uZ'
          Snacks.toggle.zen():map '<leader>uz'
        end,
      })
    end,
  },
}
