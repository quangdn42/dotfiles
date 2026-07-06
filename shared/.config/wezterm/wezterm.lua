-- Pull in the wezterm API
local wezterm = require("wezterm")
local ui = require("ui")
local keymaps = require("keymaps")
local options = require("options")

-- This table will hold the configuration.
local conf = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	conf = wezterm.config_builder()
end

-- This is where you actually apply your config choices

conf.default_prog = { "fish", "-l" }
ui.config(conf)
keymaps.config(conf)
options.config(conf)

-- and finally, return the configuration to wezterm
return conf
