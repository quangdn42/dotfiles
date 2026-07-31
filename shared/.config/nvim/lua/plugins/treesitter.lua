-- Highlight, edit, and navigate code
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      local treesitter = require 'nvim-treesitter'
      local parsers = {
        'bash',
        'c',
        'cpp',
        'diff',
        'fish',
        'go',
        'html',
        'hurl',
        'json',
        'just',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'sql',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
        'zig',
      }
      local available = treesitter.get_available()
      local installing = {}

      local function start(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr))
        local buffer_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
        if math.max(stats and stats.size or 0, buffer_size) > 100 * 1024 then
          return
        end

        local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
        if not lang then
          return
        end

        if not vim.treesitter.get_parser(bufnr, lang, { error = false }) then
          if vim.list_contains(treesitter.get_installed 'parsers', lang) or installing[lang] or not vim.list_contains(available, lang) then
            return
          end
          installing[lang] = true
          treesitter.install(lang):await(function(err, success)
            installing[lang] = nil
            if not err and success then
              vim.schedule(function()
                start(bufnr)
              end)
            end
          end)
          return
        end

        if not pcall(vim.treesitter.start, bufnr, lang) then
          return
        end
        if lang ~= 'ruby' and vim.treesitter.query.get(lang, 'indents') then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('my-treesitter', { clear = true }),
        callback = function(event)
          start(event.buf)
        end,
      })

      for _, lang in ipairs(parsers) do
        installing[lang] = true
      end
      treesitter.install(parsers):await(function(err, success)
        for _, lang in ipairs(parsers) do
          installing[lang] = nil
        end
        if not err and success then
          vim.schedule(function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(bufnr) then
                start(bufnr)
              end
            end
          end)
        end
      end)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
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
