#!/usr/bin/env lua
-- Module: returns wall(image, transition_type, transition_duration)
-- Also runnable standalone: wall <image> [transition_type] [transition_duration]

local function wall(image, transition_type, transition_duration)
	if not image then
		io.stderr:write("wall: image path is required\n")
		return false
	end
	transition_type = transition_type or "grow"
	transition_duration = transition_duration or "3"

	local h = io.popen("hyprctl cursorpos")
	local pos = h and h:read("*l") or "0 0"
	if h then
		h:close()
	end

	local pid_h = io.popen("pgrep -x awww-daemon")
	local pid = pid_h and pid_h:read("*l") or ""
	if pid_h then
		pid_h:close()
	end

	if pid == "" then
		os.execute("awww-daemon &")
		os.execute("sleep 1")
	end

	os.execute(
		"awww img"
			.. ' --transition-type "'
			.. transition_type
			.. '"'
			.. ' --transition-pos "'
			.. pos
			.. '"'
			.. ' --transition-duration "'
			.. transition_duration
			.. '"'
			.. ' "'
			.. image
			.. '"'
	)
	return true
end

-- Run directly (e.g. `lua wall.lua img.png`) but not when require()'d.
if arg and arg[0] and arg[0]:match("wall%.lua$") then
	if not arg[1] then
		io.stderr:write("Usage: wall <image> [transition_type] [transition_duration]\n")
		os.exit(1)
	end
	wall(arg[1], arg[2], arg[3])
end

return wall
