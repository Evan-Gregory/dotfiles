local os = require("os")
local io = require("io")

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

local HOME   = os.getenv("HOME")
local LOG    = HOME .. "/.local/state/hypr/autostart.log"
local CONFIG = HOME .. "/dotfiles/hypr"

hl.on("hyprland.start", function()
	exec('mkdir -p "' .. HOME .. '/.local/state/hypr"')
	log(LOG, "autostart begin")

	-- ── Environment ───────────────────────────────────────────────────────────────
	exec("dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_TYPE=wayland MOZ_ENABLE_WAYLAND=1")

	-- ── Journal: create today's entry ─────────────────────────────────────────────
	local today        = shell("date +'%Y-%m-%d'")
	local header_date  = shell("date '+%A, %B %d, %Y'")
	local journal_dir  = HOME .. "/wiki/journal"
	local journal_file = journal_dir .. "/" .. today .. ".md"
	exec('mkdir -p "' .. journal_dir .. '"')
	local jf = io.open(journal_file, "w")
	if jf then
		jf:write("# " .. header_date .. "\n## Todo: \n_________________________________________________________________________________\n")
		jf:close()
	end

	-- ── Waybar ────────────────────────────────────────────────────────────────────
	if command_exists("waybar") then
		nohup_append(
			'waybar -c "' .. HOME .. '/.config/hypr/component/waybar/config"'
			.. ' -s "' .. HOME .. '/.config/hypr/component/waybar/style.css"',
			LOG
		)
	end

	-- ── Wallpaper ─────────────────────────────────────────────────────────────────
	local wallpaper = CONFIG .. "/wallpapers/studio_gibbs.png"
	if command_exists("awww-daemon") then
		local pid = shell("pgrep -x awww-daemon")
		if pid == "" then
			exec("awww-daemon &")
			exec("sleep 1")
		end
		local pos = shell("hyprctl cursorpos")
		exec('awww img --transition-type grow --transition-pos "' .. pos .. '" --transition-duration 3 "' .. wallpaper .. '"')
	elseif command_exists("awww") then
		exec("awww init")
		exec('awww img "' .. wallpaper .. '" &')
	end

	-- ── Tmux sessions ─────────────────────────────────────────────────────────────
	local session = "default"
	if shell("tmux has-session -t " .. session .. " 2>&1; echo $?") ~= "0" then
		exec("tmux new-session -d -s " .. session .. " -n JOURNAL")
		exec("tmux new-window -t " .. session .. ":2 -n TERMINAL")
		exec("tmux new-window -t " .. session .. ":3 -n DOTS")
		exec("tmux new-window -t " .. session .. ":4 -n BTOP")
		exec("tmux send-keys -t " .. session .. ":JOURNAL 'nvim " .. journal_file .. "' C-m")
		exec("tmux send-keys -t " .. session .. ":DOTS 'cd ~/dotfiles' C-m")
		exec("tmux send-keys -t " .. session .. ":BTOP 'btop' C-m")
	end

	-- ── Notification daemon ────────────────────────────────────────────────────────
	if command_exists("dunst") then
		nohup_append("dunst", LOG)
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
