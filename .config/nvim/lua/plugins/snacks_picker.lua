return {
  -- picker
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        sources = {
          -- per picker config or new picker here, e.g.
          -- buffers = { layout = { preset = 'vscode', preview = 'main' } },
          -- files = { hidden = true },
          -- buffer_symbols = {
          --   multi = { 'treesitter', 'lsp_symbols' },
          --   transform = 'unique_file',
          -- },
          projects = {
            dev = { '~/Workspaces/', '~/projects' },
            patterns = { 'justfile', '.jj' },
          },
        },
        layout = {
          preset = function()
            return vim.o.columns >= 120 and 'default' or 'vertical'
          end,
        },
        layouts = {
          telescope = {
            reverse = true,
            layout = {
              box = 'horizontal',
              backdrop = false,
              width = 0.9,
              height = 0.9,
              border = 'none',
              {
                box = 'vertical',
                border = 'rounded',
                { win = 'list', border = 'none' },
                { win = 'input', height = 1, border = 'top', title = '{title} {live} {flags}', title_pos = 'center' },
              },
              {
                win = 'preview',
                title = '{preview:Preview}',
                width = 0.55,
                border = 'rounded',
                title_pos = 'center',
              },
            },
          },
          default = {
            layout = {
              box = 'horizontal',
              width = 0.9,
              min_width = 120,
              height = 0.8,
              {
                box = 'vertical',
                border = 'rounded',
                title = '{title} {live} {flags}',
                { win = 'input', height = 1, border = 'bottom' },
                { win = 'list', border = 'none' },
              },
              { win = 'preview', title = '{preview}', border = 'rounded', width = 0.55 },
            },
          },
          select = {
            preview = false,
            layout = {
              backdrop = false,
              width = 0.3,
              min_width = 80,
              height = 0.4,
              min_height = 10,
              box = 'vertical',
              border = 'rounded',
              title = ' Select ',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'bottom' },
              { win = 'list', border = 'none' },
              { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
            },
          },
        },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<a-.>'] = { 'toggle_hidden', mode = { 'n', 'i' } },
              ['<a-h>'] = false,
              ['<c-/>'] = { 'toggle_help', mode = { 'n', 'i' } },
            },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>b', function() Snacks.picker.buffers { filter = { cwd = true }, layout = { preset = 'vscode', preview = 'main' } } end, desc = 'Buffers' },
      { '<leader>B', function() Snacks.picker.buffers { hidden = true, nofile = true } end, desc = 'Buffers (All)' },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep (Root Dir)" },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart" },
      { "<leader>e", function() Snacks.picker.explorer() end, desc = "Explorer" },
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find Files (Root)" },
      { "<leader>F", function() Snacks.picker.files { hidden = true, ignored = true } end, desc = "Find Files (All)" },
      -- git
      { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gh", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.git_files() end, desc = "Find Files (Git)" },
      { "<leader>sG", function() Snacks.picker.grep{ cwd = vim.uv.cwd() } end, desc = "Grep (cwd)" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>sW", function() Snacks.picker.grep_word{ cwd = vim.uv.cwd() } end, desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notifications" },
      { "<leader>sp", function() Snacks.picker.zoxide() end, desc = "Projects (zoxide)" },
      { "<leader>sP", function() Snacks.picker() end, desc = "Builtin Pickers" },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.pick("undo") end, desc = "Undo" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    },
  },
}
