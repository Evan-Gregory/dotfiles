-- ===== From keybinds.conf =====

-- Unified quickshell shell: overlays toggled via IPC (shell.qml autostarted in execs.lua)
hl.bind("SUPER + Space", hl.dsp.exec_cmd("qs -p " .. HOME .. "/dotfiles/quickshell/shell.qml ipc call shell launcher"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("qs -p " .. HOME .. "/dotfiles/quickshell/shell.qml ipc call shell wallpaper"))
hl.bind("SUPER + Comma", hl.dsp.exec_cmd("qs -p " .. HOME .. "/dotfiles/quickshell/shell.qml ipc call shell settings"))
-- Lock: standalone quickshell config. Plain launch (no pgrep guard — a guard
-- self-matches its own sh -c command line and blocks the launch; ext-session-lock
-- already rejects a second concurrent lock, so a double-press is harmless).
hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("qs -p " .. HOME .. "/dotfiles/quickshell/Lock.qml"))
hl.bind("SUPER + Q", hl.dsp.window.close(), { transparent = true })
hl.bind("SUPER + C", hl.dsp.global("caelestia:controlCenter"))
hl.bind("SUPER + D", hl.dsp.global("caelestia:dashboard"))

-- Notifications
hl.bind("SUPER + SHIFT + N", hl.dsp.global("caelestia:clearNotifs")) -- dismiss all notifications
-- Do-not-disturb toggle (no global shortcut exists; drive the IPC target directly)
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("qs -c caelestia ipc call notifs toggleDnd"))

-- Media submap
hl.bind("SUPER + M", hl.dsp.submap("media"))
hl.define_submap("media", function()
	hl.bind("M", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
	hl.bind("N", hl.dsp.global("caelestia:mediaNext"), { locked = true })
	hl.bind("P", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
	hl.bind("Escape", hl.dsp.submap("reset"), { locked = true })
end)

-- Journal
hl.bind(
	"SUPER + SHIFT + J",
	hl.dsp.exec_cmd("kitty --title fly_is_journal --hold nvim ~/wiki/journal/$(date '+%Y-%m-%d').md")
)
hl.bind("SUPER + J", hl.dsp.submap("journal"))
hl.define_submap("journal", function()
	hl.bind("SHIFT + J", hl.dsp.exec_cmd(HOME .. "/dotfiles/hypr/scripts/journal.sh"))
	hl.bind("Escape", hl.dsp.submap("reset"), { locked = true })
end)

-- Screenshots / color picker
hl.bind("CTRL + S", hl.dsp.exec_cmd([[bash -c 'grim -g "$(slurp)" - | wl-copy']]))
-- hl.bind("CTRL + S", hl.dsp.exec_cmd([[bash -c 'grim -g "$(slurp)" - | swappy -f -']]))
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprpicker -n -a"))
hl.bind("CTRL + SHIFT + S", function()
	local mon = hl.get_active_monitor()
	local n = mon and mon.monitor or 1
	hl.exec_cmd("flameshot screen --number " .. n .. " --edit")
end)

-- Workspace monitor assignments
hl.workspace_rule({ workspace = 1, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 2, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 3, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 7, monitor = "DP-1" })
hl.workspace_rule({ workspace = 8, monitor = "DP-1" })
hl.workspace_rule({ workspace = 9, monitor = "DP-1" })
hl.workspace_rule({ workspace = 4, monitor = "DP-2" })
hl.workspace_rule({ workspace = 5, monitor = "DP-2" })
hl.workspace_rule({ workspace = 6, monitor = "DP-2" })

-- Workspace focus (remapped)
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

-- Move to workspace (remapped)
hl.bind("ALT + 1", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind("ALT + 2", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind("ALT + 3", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind("ALT + 4", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind("ALT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind("ALT + 6", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind("ALT + 7", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind("ALT + 8", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind("ALT + 9", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind("ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- ===== From hyprland.conf =====

-- Mouse window management
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scroll workspace
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Window movement (misc)
-- hl.bind("ALT + Tab", hl.dsp.window.move({ position = { 1100, 80 } }))

-- Layout
hl.bind("SUPER + M", hl.dsp.layout("swapwithmaster master"))
-- Equalize the active split so both windows take half (SUPER + |)
hl.bind("SUPER + SHIFT + backslash", hl.dsp.layout("splitratio 1.0 exact"))

-- Special workspaces
hl.bind("CTRL + SUPER + M", hl.dsp.workspace.toggle_special("media"))
hl.bind("CTRL + SUPER + T", hl.dsp.workspace.toggle_special("teams"))
hl.bind("CTRL + SUPER + J", hl.dsp.workspace.toggle_special("journal"))
hl.bind("CTRL + SUPER + C", hl.dsp.workspace.toggle_special("clear"))

-- Terminal / kitty
hl.bind(
	"SUPER + T",
	hl.dsp.exec_cmd(
		"kitty --start-as=fullscreen -o 'font_size=14' --title all_is_kitty --hold sh -c 'tmux attach -t default'"
	)
)
hl.bind("SUPER + SHIFT + Tab", hl.dsp.exec_cmd("kitty --title fly_is_kitty --hold sh -c 'tmux new-session'"))
hl.bind(
	"SUPER + Tab",
	hl.dsp.exec_cmd(
		"kitty --title fly_is_kitty --hold sh -c 'tmux attach -t fly_is_kitty || tmux new-session -s fly_is_kitty'"
	)
)
-- hl.bind("SUPER + Tab", hl.dsp.group.change_active())
hl.bind("Print", hl.dsp.exec_cmd(HOME .. "/.config/hypr/scripts/screenshot"))

-- Window state
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind("SUPER + S", hl.dsp.window.resize({ x = 800, y = 500, "exact" }))
hl.bind("SUPER + S", hl.dsp.window.center())

-- Focus movement
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + N", hl.dsp.focus({ window = "activewindow" }))
-- hl.get_windows()
-- hl.bind("SUPER + N", hl.dsp.window.bring_to_top())

-- Apps
hl.bind("SUPER + B", hl.dsp.exec_cmd("blueman-manager"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("pavucontrol"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("1password"))
hl.bind("SUPER + SHIFT + J", hl.dsp.exec_cmd(HOME .. "/dotfiles/hypr/scripts/journal.sh"))

-- Misc kitty spawns
hl.bind("CTRL + 1", hl.dsp.exec_cmd("kitty --title fly_is_cava --hold cava"))
hl.bind("CTRL + 2", hl.dsp.exec_cmd("kitty --title vim_is_kitty --hold nvim"))
hl.bind("CTRL + 3", hl.dsp.exec_cmd("kitty --title fly_is_kitty --hold ~/Documents/donut/a.out"))
hl.bind("CTRL + 4", hl.dsp.exec_cmd("kitty --title clock_is_kitty --hold tty-clock -C5 -s -S"))
hl.bind("CTRL + 5", hl.dsp.exec_cmd("kitty --single-instance --start-as=fullscreen --hold btop"))
