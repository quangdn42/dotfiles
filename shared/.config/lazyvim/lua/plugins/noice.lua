return {
  {
    "folke/noice.nvim",
    optional = true,
    enabled = true,
    keys = function()
			-- stylua: ignore
      return {
        { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" } },
        { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" } },
      }
    end,
  },
}
