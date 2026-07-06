return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      mode = { "n", "v" },
      {
        "<leader>b",
        group = "buffer",
      },
      {
        "<leader>w",
        group = "windows",
        proxy = "<c-w>",
      },
    },
  },
}
