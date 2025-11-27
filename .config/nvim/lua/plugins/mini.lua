return {
  -- Better text-objects
  {
    'echasnovski/mini.ai',
    version = '*',
    event = 'VeryLazy',
    opts = function()
      local ai = require 'mini.ai'
      local function ai_line(ai_type)
        local line_num = vim.fn.line '.'
        local line = vim.fn.getline(line_num)
        -- Ignore indentation for `i` textobject
        local from_col = ai_type == 'a' and 1 or (line:match('^(%s*)'):len() + 1)
        -- Don't select `\n` past the line to operate within a line
        local to_col = line:len()

        return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } }
      end

      return {
        n_lines = 100,
        custom_textobjects = {
          A = ai.gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' }, -- TS argument
          o = ai.gen_spec.treesitter { -- code block
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          },
          -- k = ai.gen_spec.treesitter { a = '@assignment.lhs', i = '@assignment.lhs' }, -- assignment key
          -- v = ai.gen_spec.treesitter { a = '@assignment.rhs', i = '@assignment.rhs' }, -- assignment value
          f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' }, -- function
          -- c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
          T = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
          -- e = { -- Word with case
          --   { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          --   '^().*()$',
          -- },
          y = ai_line, -- line
          e = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line '$',
              col = math.max(vim.fn.getline('$'):len(), 1),
            }
            return { from = from, to = to }
          end, -- buffer
          F = ai.gen_spec.function_call(), -- u for "Usage"
        },
      }
    end,
  },

  -- hipatterns
  -- NOTE: consider https://github.com/catgoose/nvim-colorizer.lua when working with FE
  {
    'echasnovski/mini.hipatterns',
    version = '*',
    event = 'BufReadPre',
    config = function()
      local hipatterns = require 'mini.hipatterns'
      hipatterns.setup {
        highlighters = {

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },

  -- indentscope
  {
    'echasnovski/mini.indentscope',
    version = '*',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      symbol = '│',
      options = { try_as_border = true },
      mappings = {
        goto_top = '[=',
        goto_bottom = ']=',
      },
      draw = {
        predicate = function()
          return false
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'Trouble',
          'alpha',
          'dashboard',
          'fzf',
          'help',
          'lazy',
          'mason',
          'neo-tree',
          'notify',
          'snacks_dashboard',
          'snacks_notif',
          'snacks_terminal',
          'snacks_win',
          'toggleterm',
          'trouble',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SnacksDashboardOpened',
        callback = function(data)
          vim.b[data.buf].miniindentscope_disable = true
        end,
      })
    end,
    keys = {
      {
        'oi',
        function()
          if vim.v.operator == 'd' then
            local scope = require('mini.indentscope').get_scope()
            if scope.border.indent == -1 then
              return 'oi'
            end
            local top = scope.border.top
            local bottom = scope.border.bottom
            local row = scope.reference.line
            local move = ''
            if row == bottom then
              move = 'k'
            elseif row == top then
              move = 'j'
            end
            local ns = vim.api.nvim_create_namespace 'border'
            vim.hl.range(0, ns, 'Substitute', { top - 1, 0 }, { top - 1, -1 })
            vim.hl.range(0, ns, 'Substitute', { bottom - 1, 0 }, { bottom - 1, -1 })
            vim.defer_fn(function()
              vim.cmd('silent' .. tostring(top .. ',' .. bottom .. '<'))
              vim.cmd(tostring(bottom .. 'delete'))
              vim.cmd(tostring(top .. 'delete'))
              vim.fn.setcursorcharpos(row - 1, scope.reference.column)
              vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            end, 150)
            return '<esc>' .. move
          else
            return 'oi'
          end
        end,
        expr = true,
        mode = 'o',
        desc = 'Outer indent border',
      },
    },
  },

  -- move
  {
    'echasnovski/mini.move',
    version = '*',
    event = 'VeryLazy',
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<M-left>',
        right = '<M-right>',
        down = '<M-down>',
        up = '<M-up>',

        -- Move current line in Normal mode
        line_left = '<M-left>',
        line_right = '<M-right>',
        line_down = '<M-down>',
        line_up = '<M-up>',
      },
    },
  },

  -- surround
  {
    'echasnovski/mini.surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('mini.surround').setup {
        mappings = {
          add = 'ys', -- Add surrounding in Normal and Visual modes
          delete = 'ds', -- Delete surrounding
          find = '', -- Find surrounding (to the right)
          find_left = '', -- Find surrounding (to the left)
          highlight = '', -- Highlight surrounding
          replace = 'cs', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`

          suffix_last = '',
          suffix_next = '',
        },
        search_method = 'cover_or_next',
      }
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
