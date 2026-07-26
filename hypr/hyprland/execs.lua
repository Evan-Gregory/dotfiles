local os = require("os")
local io = require("io")
local wall = require("scripts.wall")

local function exec(cmd)
	return os.execute(cmd)
end

local function shell(cmd)
	local h = io.popen(cmd)
	if not h then
		return ""
	end
	local out = h:read("*a"):gsub("%s+$", "")
	h:close()
	return out
end

local function is_executable(path)
	return os.execute('test -x "' .. path .. '"') == 0
end

local function command_exists(cmd)
	return os.execute('command -v "' .. cmd .. '" >/dev/null 2>&1') == 0
end

local function log(file, msg)
	local ts = shell("date --iso-8601=seconds")
	local f = io.open(file, "a")
	if f then
		f:write(ts .. "  " .. msg .. "\n")
		f:close()
	end
end

local function nohup_append(cmd, logfile)
	exec("nohup " .. cmd .. ' >> "' .. logfile .. '" 2>&1 &')
end

local HOME = os.getenv("HOME")
local LOG = HOME .. "/.local/state/hypr/autostart.log"
local CONFIG = HOME .. "/dotfiles/hypr"

hl.on("hyprland.start", function()
	exec('mkdir -p "' .. HOME .. '/.local/state/hypr"')
	log(LOG, "autostart begin")

	-- ── Lockscreen ────────────────────────────────────────────────────────────────
	-- Launch first so the ext-session-lock engages as early as possible. greetd
	-- autologins with no password, so this lock is the first authentication gate.
	nohup_append("qs -p " .. HOME .. "/dotfiles/quickshell/Lock.qml", LOG)

	-- ── Environment ───────────────────────────────────────────────────────────────
	exec(
		"dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_TYPE=wayland MOZ_ENABLE_WAYLAND=1"
	)

	-- ── Wallpaper ─────────────────────────────────────────────────────────────────
	wall(CONFIG .. "/wallpapers/f.jpg")

	-- ── Unified quickshell shell (wallpaper + launcher overlays via IPC) ───────────
	-- Background daemon; keybinds (SUPER+Space / SUPER+W) toggle its overlays.
	if command_exists("qs") then
		nohup_append("qs -p " .. HOME .. "/dotfiles/quickshell/shell.qml", LOG)
		nohup_append("qs -p " .. HOME .. "/dotfiles/quickshell/visualiser", LOG)
	else
		log("Shell unable to initialize")
	end

	-- ── Tmux sessions ─────────────────────────────────────────────────────────────
	local session = "default"
	if shell("tmux has-session -t " .. session .. " 2>&1; echo $?") ~= "0" then
		exec("tmux new-session -d -s " .. session .. " -n JOURNAL")
		exec("tmux new-window -t " .. session .. ":2 -n TERMINAL")
		exec("tmux new-window -t " .. session .. ":3 -n DOTS")
		exec("tmux new-window -t " .. session .. ":4 -n BTOP")
		exec("tmux send-keys -t " .. session .. ":DOTS 'cd ~/dotfiles' C-m")
		exec("tmux send-keys -t " .. session .. ":BTOP 'btop' C-m")
	end

	-- ── Notification daemon ────────────────────────────────────────────────────────
	if command_exists("dunst") then
		nohup_append("dunst", LOG)
	end

	-- ── Flameshot daemon ───────────────────────────────────────────────────────────
	-- Flameshot (v14+) captures via the xdg-desktop-portal Screenshot API, which
	-- needs graphical-session.target up — see hypr/autostart / PORTAL-SESSION.md.
	if command_exists("flameshot") then
		nohup_append("flameshot", LOG)
	end

	-- ── PolicyKit agent ───────────────────────────────────────────────────────────
	local polkit = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
	if is_executable(polkit) then
		nohup_append('"' .. polkit .. '"', LOG)
	end

	-- ── DBus environment for later-launched apps ──────────────────────────────────
	nohup_append("dbus-update-activation-environment --systemd --all", LOG)

	-- ── Hello toast ───────────────────────────────────────────────────────────────
	if command_exists("notify-send") then
		exec("notify-send -a aurora 'hello " .. shell("whoami") .. "'")
	end

	log(LOG, "autostart end")
end)
