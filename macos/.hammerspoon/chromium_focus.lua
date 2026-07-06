-- chrome_focus.lua
local M = {}

local TARGET_APPS = {
	["Google Chrome"] = true,
	["Microsoft Edge"] = true,
}

local pendingTimer = nil
local appWatcher = nil

local function isOmniboxFocused(el)
	if not el then
		return false
	end

	local role = el:attributeValue("AXRole")
	if role ~= "AXTextField" and role ~= "AXComboBox" and role ~= "AXSearchField" then
		return false
	end

	-- Conservative fallback: treat focused textfield-ish element as omnibox.
	return true
end

local function forceFocus()
	local frontApp = hs.application.frontmostApplication()
	if not frontApp or not TARGET_APPS[frontApp:name()] then
		return
	end

	local systemEl = hs.axuielement.systemWideElement()
	local focusedEl = systemEl and systemEl:attributeValue("AXFocusedUIElement")

	if isOmniboxFocused(focusedEl) then
		return
	end

	hs.eventtap.keyStroke({ "cmd" }, "l", 0)
	hs.eventtap.keyStroke({}, "escape", 0)
end

function M.setup(opts)
	opts = opts or {}
	local delay = opts.delay or 0.02

	-- idempotent setup
	if appWatcher then
		return M
	end

	appWatcher = hs.application.watcher.new(function(appName, eventType, app)
		if eventType ~= hs.application.watcher.activated then
			return
		end
		if not TARGET_APPS[appName] then
			return
		end

		-- Prevent stacking callbacks on rapid app switching
		if pendingTimer then
			pendingTimer:stop()
			pendingTimer = nil
		end

		pendingTimer = hs.timer.doAfter(delay, function()
			pendingTimer = nil
			forceFocus()
		end)
	end)

	appWatcher:start()
	return M
end

function M.stop()
	if pendingTimer then
		pendingTimer:stop()
		pendingTimer = nil
	end
	if appWatcher then
		appWatcher:stop()
		appWatcher = nil
	end
	return M
end

return M
