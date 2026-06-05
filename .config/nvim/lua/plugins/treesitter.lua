-- Highlight, edit, and navigate code
return {
  {
    'nvim-treesitter/nvim-treesitter',
    commit = 'cf12346a3414fa1b06af75c79faebe7f76df080a',
    build = ':TSUpdate',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    event = 'VeryLazy',
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts

    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },

      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,

        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },

        -- list of language that will be disabled
        -- disable = { 'c', 'rust' },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files

        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true, disable = { 'ruby' } },

      incremental_selection = {
        enable = false,
        keymaps = {
          init_selection = false,
          node_incremental = '<a-o>',
          scope_incremental = '<a-a>',
          node_decremental = '<a-i>',
        },
      },
      textobjects = {
        move = {
          enable = false,
          goto_next_start = { [']f'] = '@function.outer', [']a'] = '@parameter.inner', [']k'] = '@assignment.lhs', [']v'] = '@assignment.rhs' },
          goto_next_end = { [']F'] = '@function.outer', [']A'] = '@parameter.inner', [']K'] = '@assignment.lhs', [']V'] = '@assignment.rhs' },
          goto_previous_start = { ['[f'] = '@function.outer', ['[a'] = '@parameter.inner', ['[k'] = '@assignment.lhs', ['[v'] = '@assignment.rhs' },
          goto_previous_end = { ['[F'] = '@function.outer', ['[A'] = '@parameter.inner', ['[K'] = '@assignment.lhs', ['[V'] = '@assignment.rhs' },
        },
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    commit = 'b311b30818951d01f7b4bf650521b868b3fece16',
    event = 'VeryLazy',
    opts = function()
      local tsc = require 'treesitter-context'
      Snacks.toggle({
        name = 'Treesitter Context',
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map '<leader>ut'
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- Comments
  {
    'folke/ts-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
}
-- vim: ts=2 sts=2 sw=2 et
