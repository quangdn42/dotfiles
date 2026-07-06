return {
  {
    "folke/persistence.nvim",
		-- stylua: ignore
    keys = {
      { "<leader>qs", false },
      { "<leader>qS", false },
      { "<leader>qr", function() require("persistence").load() end, desc = "Restore Session (Current Dir)" },
      { "<leader>qR", function() require("persistence").select() end, desc = "Select Session" },
    },
  },
}
