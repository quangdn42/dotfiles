return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {},
        gopls = {
          settings = {
            gopls = {
              hints = {
                parameterNames = false,
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                functionTypeParameters = false,
              },
              analyses = {
                fieldalignment = false,
              },
            },
          },
        },
      },
    },
  },
  {
    "olexsmir/gopher.nvim",
    event = "VeryLazy",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd([[silent! GoInstallDeps]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "templ",
      })
    end,
  },
  {
    "laytan/tailwind-sorter.nvim",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    build = "cd formatter && npm ci && npm run build",
    opts = {
      on_save_enabled = true, -- If `true`, automatically enables on save sorting.
      on_save_pattern = {
        "*.html",
        "*.js",
        "*.jsx",
        "*.tsx",
        "*.twig",
        "*.hbs",
        "*.php",
        "*.heex",
        "*.astro",
        "*.templ",
      }, -- The file patterns to watch and sort.
      node_path = "node",
    },
  },
}
