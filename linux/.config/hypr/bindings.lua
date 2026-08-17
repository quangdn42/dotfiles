-- Personal bindings ported from the pre-Omarchy-4 Hyprland configuration.
-- Omarchy defaults remain active unless explicitly unbound below.

-- Restore HJKL window focus. Super+J and Super+L replace the v4 split and
-- workspace-layout toggles, which move back to their previous Ctrl variants.
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + CTRL + J")
hl.unbind("SUPER + CTRL + K")
hl.unbind("SUPER + CTRL + L")

o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + CTRL + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Restore the named workspace layer.
local named_workspaces = {
  { key = "A", id = "11", name = "Home" },
  { key = "S", id = "12", name = "Messages" },
  { key = "D", id = "13", name = "Development" },
  { key = "E", id = "14", name = "Editing" },
  { key = "F", id = "15", name = "Web" },
}

for _, workspace in ipairs(named_workspaces) do
  hl.workspace_rule({ workspace = workspace.id, persistent = true })
  hl.unbind("SUPER + " .. workspace.key)
  hl.unbind("SUPER + SHIFT + " .. workspace.key)
  o.bind(
    "SUPER + " .. workspace.key,
    workspace.name .. " workspace",
    hl.dsp.focus({ workspace = workspace.id })
  )
  o.bind(
    "SUPER + SHIFT + " .. workspace.key,
    "Move window to " .. workspace.name .. " workspace",
    hl.dsp.window.move({ workspace = workspace.id, follow = false })
  )
end

-- Keep number-row moves silent, matching the previous configuration.
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + SHIFT + " .. key)
  o.bind(
    "SUPER + SHIFT + " .. key,
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace), follow = false })
  )
end

-- Restore workspace navigation keys. Super+P replaces v4's pseudo-window key;
-- pseudo-window moves back to Super+Ctrl+T.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + P")
hl.unbind("SUPER + CTRL + T")
o.bind("SUPER + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("SUPER + N", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + P", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + CTRL + T", "Pseudo window", hl.dsp.window.pseudo())

-- Restore the old fullscreen and width controls.
o.bind("SUPER + M", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + CTRL + M", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Restore resize arrows. Left/right replace v4's grouped-window focus aliases;
-- group navigation remains available on Super+Alt+Tab and its reverse.
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + CTRL + LEFT", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + CTRL + RIGHT", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("SUPER + CTRL + UP", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("SUPER + CTRL + DOWN", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Super+scroll cycles windows; adding Shift cycles workspaces.
hl.unbind("SUPER + mouse_up")
hl.unbind("SUPER + mouse_down")
o.bind("SUPER + mouse_up", "Scroll active window forward", hl.dsp.window.cycle_next())
o.bind("SUPER + mouse_down", "Scroll active window backward", hl.dsp.window.cycle_next({ next = false }))
o.bind("SUPER + SHIFT + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + SHIFT + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

-- Scrolling-layout column size. Resize arrows above retain general resizing.
hl.unbind("SUPER + code:20")
hl.unbind("SUPER + code:21")
o.bind("SUPER + EQUAL", "Increase scrolling column width", hl.dsp.layout("colresize +conf"))
o.bind("SUPER + MINUS", "Decrease scrolling column width", hl.dsp.layout("colresize -conf"))

-- Activate grouped windows by number without consuming the number-row
-- workspace shortcuts.
for index = 1, 5 do
  o.bind("CTRL + code:" .. tostring(index + 9), "Switch to group window " .. index, hl.dsp.group.active({ index = index }))
end

-- Restore the previous application aliases while keeping equivalent v4 keys.
o.bind("SUPER + ALT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + ALT + D", "Docker", { tui = "lazydocker" })
o.bind("SUPER + ALT + M", "Music", { omarchy = "spotify" })

-- Super+Alt+F replaces v4 full-width; full-width is restored above on
-- Super+Ctrl+M. Super+Ctrl+Q replaces v4 Calculator; Calculator remains on the
-- dedicated XF86 key.
hl.unbind("SUPER + ALT + F")
hl.unbind("SUPER + CTRL + Q")
o.bind("SUPER + ALT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + CTRL + Q", "Lock system", "omarchy-system-lock")

-- vim: ts=2 sts=2 sw=2 et
