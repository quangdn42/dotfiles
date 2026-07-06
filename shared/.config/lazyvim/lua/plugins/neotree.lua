return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    opts = {
      window = {
        mappings = {
          ["h"] = "close_node",
          ["l"] = "open",
          ["s"] = {
            function()
              require("flash").jump()
            end,
            desc = "flash",
          },
          ["|"] = "open_vsplit",
          ["-"] = "open_split",
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_gitignored = false,
        },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            -- auto close
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
    },
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>be", false },
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      -- { "<leader>E", false },
      -- { "<leader>e", false },
    },
  },
}
