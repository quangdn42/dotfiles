local wezterm = require("wezterm")
local act = wezterm.action
local split = require("split_nav")

local M = {}

function M.config(config)
	-- Use command for most wezterm level operation
	config.keys = {
		-- Pane
		{ key = "Enter", mods = "SUPER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "Enter", mods = "SUPER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "m", mods = "SUPER", action = act.TogglePaneZoomState },
		-- move between split panes
		split.nav("move", "h"),
		split.nav("move", "j"),
		split.nav("move", "k"),
		split.nav("move", "l"),
		-- resize panes
		split.nav("resize", "LeftArrow"),
		split.nav("resize", "DownArrow"),
		split.nav("resize", "UpArrow"),
		split.nav("resize", "RightArrow"),

		-- CopyMode
		{ key = "x", mods = "SUPER", action = act.ActivateCopyMode },
		{ key = "x", mods = "SUPER|SHIFT", action = act.QuickSelect },

		-- Command pallete
		{ key = "p", mods = "SUPER|SHIFT", action = act.ActivateCommandPalette },

		-- Tabs
		-- { key = "k", mods = "SUPER", action = act.ActivateTabRelative(-1) },
		-- { key = "j", mods = "SUPER", action = act.ActivateTabRelative(1) },
		-- { key = "h", mods = "SUPER", action = act.ActivateTabRelative(-1) },
		-- { key = "l", mods = "SUPER", action = act.ActivateTabRelative(1) },
		{ key = "Tab", mods = "CTRL", action = act.ActivateLastTab },
		{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateLastTab },

		-- passthrough for wm
		{ key = "h", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "j", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "k", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "l", mods = "ALT", action = act.DisableDefaultAssignment },

		-- clear scrollback
		{ key = "k", mods = "SUPER", action = act.SendKey({ key = "l", mods = "CTRL" }) },

		-- workspace launcher
		{ key = "o", mods = "SUPER", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },
		{
			key = "n",
			mods = "SUPER|SHIFT",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:perform_action(
							act.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
	}

	-- Hold config for key_tables
	config.key_tables = {}

	-- CopyMode and SearchMode mappings
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/CopyMode/AcceptPattern.html
	local copy_mode = nil
	local search_mode = nil
	local copy_mode_mappings = {
		{ key = "/", mods = "NONE", action = act.CopyMode("EditPattern") },
		{
			key = "Escape",
			mods = "NONE",
			action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.CopyMode("ClearPattern") }),
		},
		{ key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "n", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
	}
	local search_mode_mappings = {
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("AcceptPattern"),
		},
	}
	-- https://wezfurlong.org/wezterm/config/lua/wezterm.gui/default_key_tables.html
	if wezterm.gui then
		copy_mode = wezterm.gui.default_key_tables().copy_mode
		for _, key in pairs(copy_mode_mappings) do
			table.insert(copy_mode, key)
		end
		search_mode = wezterm.gui.default_key_tables().search_mode
		for _, key in pairs(search_mode_mappings) do
			table.insert(search_mode, key)
		end
	end
	config.key_tables.copy_mode = copy_mode
	config.key_tables.search_mode = search_mode
end

return M
