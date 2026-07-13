local wezterm = require("wezterm")
local M = {}

-- [[
-- SPLIT NAVIGATION
-- ]]
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end
local direction_move_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
	LeftArrow = "Left",
	DownArrow = "Down",
	UpArrow = "Up",
	RightArrow = "Right",
}
local direction_resize_keys = {
	LeftArrow = "Left",
	DownArrow = "Down",
	UpArrow = "Up",
	RightArrow = "Right",
	Home = "Left",
	PageDown = "Down",
	PageUp = "Up",
	End = "Right",
}

function M.nav(resize_or_move, key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_resize_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_move_keys[key] }, pane)
				end
			end
		end),
	}
end

return M
