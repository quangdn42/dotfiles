local cmp = require("cmp")
return {
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = {
      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = {},
        ["<C-y>"] = LazyVim.cmp.confirm(),
        ["<C-e>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-m>"] = LazyVim.cmp.confirm(), -- for qwerty layout
        ["<Tab>"] = {},
        ["<C-Right>"] = function(fallback)
          return LazyVim.cmp.map({ "snippet_forward" }, fallback)()
        end,
      }),
    },
  },
}
