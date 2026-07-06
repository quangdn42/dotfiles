local M = {}

function M.config(config)
	config.enable_kitty_keyboard = true
	config.force_reverse_video_cursor = true
	config.max_fps = 120
	-- config.window_background_opacity = 0.9
	config.unzoom_on_switch_pane = true
end

return M
