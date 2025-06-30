return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
    },
    keys = {
    -- stylua: ignore start
    { '<F3>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F2>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F1>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<F4>', function() require('dap').step_back() end, desc = 'Debug: Step Back' },
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F6>', function() require('dap').restart() end, desc = 'Debug: Restart' },
    { '<F9>', function() require('dap').down() end, desc = 'Debug: Previous stack frame' },
    { '<F7>', function() require('dap').up() end, desc = 'Debug: Next stack frame' },
    { '<leader>dl', function() require('dap').run_last() end, desc = 'Run last debug session' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Set Breakpoint' },
      -- stylua: ignore end
    },
    config = function()
      local dap = require 'dap'
      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      -- local breakpoint_icons = { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      local breakpoint_icons = { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end
      --
      -- configure codelldb adapter
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = 'codelldb',
          args = { '--port', '${port}' },
        },
      }
      -- setup a debugger for zig projects
      dap.configurations.zig = {
        {
          name = 'Launch',
          type = 'codelldb',
          request = 'launch',
          program = '${workspaceFolder}/zig-out/bin/${workspaceFolderBasename}',
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
      -- Install golang specific config
      require('dap-go').setup()
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'nvim-neotest/nvim-nio' },
    keys = {
      -- stylua: ignore start
      { '<leader>du', function() require('focus').focus_toggle() require('dapui').toggle {} end, desc = 'Dap UI' },
      { '<leader>de', function() require('dapui').eval() end, desc = 'Eval', mode = {'n', 'v'} },
      -- stylua: ignore end
    },
    config = function()
      -- Dap UI setup, see |:help nvim-dap-ui|
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup {
        controls = {
          element = 'console',
        },
        layouts = {
          {
            elements = {
              { id = 'console', size = 0.5 },
              { id = 'repl', size = 0.5 },
            },
            position = 'bottom',
            size = 15,
          },
          {
            elements = {
              { id = 'scopes', size = 0.5 },
              { id = 'breakpoints', size = 0.2 },
              { id = 'stacks', size = 0.15 },
              { id = 'watches', size = 0.15 },
            },
            position = 'top',
            size = 10,
          },
        },
      }

      local function dapui_off()
        dapui.close()
        require('focus').focus_enable()
      end

      dap.listeners.after.event_initialized['dapui_config'] = function()
        require('focus').focus_disable()
        dapui.open {}
      end
      dap.listeners.before.event_terminated['dapui_config'] = dapui_off
      dap.listeners.before.event_exited['dapui_config'] = dapui_off
    end,
  },
}
