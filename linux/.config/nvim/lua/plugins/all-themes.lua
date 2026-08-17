return {
	-- Load all theme plugins but don't apply them
	-- This ensures all colorschemes are available for hot-reloading
	{
		"ribru17/bamboo.nvim",
		lazy = true,
		priority = 1000,
	},
	-- Name and branch must match Omarchy 4's generated theme spec
	-- (default/themed/neovim.lua.tpl). lazy merges specs by url and lets an
	-- explicit name rename the merged plugin, so a bare "bjarneo/aether.nvim"
	-- here builds the cache into lazy/aether.nvim while every aether-themed
	-- Omarchy 4 install renames it to lazy/aether at runtime -- a directory the
	-- package never shipped. That cost a network clone on first launch, and the
	-- theme fell back to tokyonight until nvim was restarted.
	{
		"bjarneo/aether.nvim",
		branch = "v3",
		name = "aether",
		lazy = true,
		priority = 1000,
	},
	{
		"bjarneo/hackerman.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
		opts = {
			dim_inactive = { enabled = false },
			custom_highlights = function(colors)
				return {
					FlashLabel = { fg = colors.crust, bg = colors.red, style = { "bold" } },
					FlashMatch = { fg = colors.text, bg = "#355868" },
					FlashCurrent = { fg = colors.crust, bg = colors.sky },
					InclineNormal = { fg = colors.peach, bg = colors.crust },
					CmpItemAbbrMatch = { fg = colors.blue },
					CmpItemAbbr = { fg = colors.text },
					PmenuBorder = { bg = colors.text },
					WindlineModeNormal = { fg = colors.mauve },
					WindlineModeInsert = { fg = colors.teal },
					WindlineModeVisual = { fg = colors.yellow },
					WindlineModeReplace = { fg = colors.lavender },
					WindlineModeCommand = { fg = colors.maroon },
					ColorColumn = { bg = colors.red },
				}
			end,
		},
	},
	{
		"neanias/everforest-nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"kepano/flexoki-neovim",
		lazy = true,
		priority = 1000,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		priority = 1000,
		opts = {
			compile = true,
			colors = {
				theme = {
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
			overrides = function(colors)
				local theme = colors.theme
				local palette = colors.palette
				return {
					FlashLabel = { fg = palette.lotusCyan, bg = palette.samuraiRed, bold = true },
					FlashMatch = { fg = palette.lotusCyan, bg = palette.lotusBlue4 },
					FlashCurrent = { fg = palette.sumiInk2, bg = palette.surimiOrange },
					EyelinerPrimary = { fg = palette.surimiOrange },
					EyelinerSecondary = { fg = palette.springBlue },
					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend },
					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = theme.ui.bg_p2 },
					ColorColumn = { bg = palette.samuraiRed },
				}
			end,
		},
	},
	{
		"tahayvr/matteblack.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 1000,
	},
	{
		"ficcdaf/ashen.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		version = "*",
		priority = 1000,
		opts = {
			transparent = false,
			on_highlights = function(hl, colors)
				hl["SnacksDashboardHeader"] = { fg = colors.blue2 }
				hl["WinBar"] = { bg = colors.bg }
				hl["WinBarNC"] = { bg = colors.bg }
				hl["ColorColumn"] = { bg = colors.red }
			end,
			on_colors = function(colors)
				colors.border = colors.blue2
			end,
		},
	},
	{
		"OldJobobo/retro-82.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"omacom-io/lumon.nvim",
		lazy = true,
		priority = 1000,
	},
}
