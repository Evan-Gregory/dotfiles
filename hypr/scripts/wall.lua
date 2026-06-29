#!/usr/bin/env lua
-- Usage: wall <image> [transition_type] [transition_duration]
local image = arg[1]
if not image then
    io.stderr:write("Usage: wall <image> [transition_type] [transition_duration]\n")
    os.exit(1)
end
local transition_type     = arg[2] or "grow"
local transition_duration = arg[3] or "3"

local h = io.popen("hyprctl cursorpos")
local pos = h and h:read("*l") or "0 0"
if h then h:close() end

local pid_h = io.popen("pgrep -x awww-daemon")
local pid   = pid_h and pid_h:read("*l") or ""
if pid_h then pid_h:close() end

if pid == "" then
    os.execute("awww-daemon &")
    os.execute("sleep 1")
end

os.execute(
    'awww img'
    .. ' --transition-type "' .. transition_type .. '"'
    .. ' --transition-pos "'  .. pos              .. '"'
    .. ' --transition-duration "' .. transition_duration .. '"'
    .. ' "' .. image .. '"'
)
