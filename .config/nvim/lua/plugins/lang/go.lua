return {
  {
    'nvimtools/none-ls.nvim',
    ft = 'go',
    opts = function(_, opts)
      local nls = require 'null-ls'
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.gomodifytags,
      })
    end,
  },
  {
    'fang2hou/go-impl.nvim',
    lazy = true,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    opts = {},
  },
}
