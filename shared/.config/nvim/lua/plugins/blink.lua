return {
  {
    'saghen/blink.cmp',
    event = { 'CmdlineEnter', 'InsertEnter' },
    dependencies = {
      { 'rafamadriz/friendly-snippets' },
      -- to add luasnip look at https://cmp.saghen.dev/configuration/snippets.html#luasnip
      -- { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    },

    -- use a release tag to download pre-built binaries
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },
      cmdline = {
        completion = {
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ':'
              -- enable for inputs as well, with:
              -- or vim.fn.getcmdtype() == '@'
            end,
          },
          -- for cmdline, do not preselect first option. only select when item is chosen
          list = {
            selection = {
              preselect = false,
            },
          },
        },
      },

      completion = {
        menu = {
          -- nvim-cmp style menu
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
            },
            treesitter = { 'lsp' },
          },
        },
        -- Show documentation when selecting a completion item
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            min_width = 10,
            max_width = 120,
            max_height = 40,
          },
        },

        -- Display a preview of the selected item on the current line
        ghost_text = { enabled = true },
      },

      -- Experimental signature help support
      signature = { enabled = true },

      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { 'sources.default' },
  },

  -- LazyDev source
  {
    'saghen/blink.cmp',
    optional = true,
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { 'lazydev' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
    },
  },
}
