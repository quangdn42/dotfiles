local out = {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      scroll = {
        enabled = false,
        animate = {
          duration = { step = 15, total = 100 },
          easing = "linear",
        },
        -- faster animation when repeating scroll after delay
        animate_repeat = {
          delay = 100, -- delay in ms before using the repeat animation
          duration = { step = 5, total = 30 },
          easing = "linear",
        },
      },
    },
  },
}

if LazyVim.pick.picker.name == "snacks" then
  out[#out + 1] = {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        layouts = {
          default = {
            layout = {
              box = "horizontal",
              width = 0.9,
              min_width = 120,
              height = 0.8,
              {
                box = "vertical",
                border = "rounded",
                title = "{title} {live} {flags}",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", title = "{preview}", border = "rounded", width = 0.55 },
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
            },
          },
        },
      },
    },
		-- stylua: ignore
		keys = {
			{ "<leader>f", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
			{ "<leader>F", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
			{ "<leader>,", false },
			{ "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
			{ "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart" },

			{ "<leader>sP", function() Snacks.picker() end, desc = "Builtin Pickers" },
			{ "<leader>sp", function() Snacks.picker.zoxide() end, desc = "Projects (zoxide)" },
			{ "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },
			{ "<leader>su", function() Snacks.picker.pick("undo") end, desc = "Undo" },

      { "<leader>n", false },
      {
        "<leader>sn",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification History",
      },

			{ "<leader>fb", false },
			{ "<leader>fc", false },
			{ "<leader>ff", false },
			{ "<leader>fF", false },
			{ "<leader>fg", false },
			{ "<leader>fr", false },
			{ "<leader>fR", false },
			{ "<leader>fp", false },
		},
  }
end

return out
