return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<a-o>",
          node_incremental = "<a-o>",
          scope_incremental = "<a-a>",
          node_decremental = "<a-i>",
        },
      },
    },
  },
}
