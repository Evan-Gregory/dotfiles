#!/usr/bin/env lua
-- Waybar custom module: wallpaper cycling and toolbar icon polling.
-- Usage: expand [cycle|arrow-icon|ss-icon]
local HOME    = os.getenv("HOME")
local hypr    = HOME .. "/.config/hypr"
local scripts = hypr .. "/scripts"
local TEMP    = "/tmp/current_wall"
local LOCK    = "/tmp/expand_toolbar.lock"
local COOLDOWN = 0.1

local function toolbar_expanded()
    local f = io.open(LOCK, "r")
    if f then f:close(); return true end
    return false
end

local function ls_wallpapers()
    local files = {}
    local p = io.popen('ls "' .. hypr .. '/wallpapers/"')
    if p then
        for name in p:lines() do
            table.insert(files, hypr .. "/wallpapers/" .. name)
        end
        p:close()
    end
    return files
end

local mode = arg and arg[1] or ""

if mode == "cycle" then
    local files = ls_wallpapers()
    local index = 0
    local rf = io.open(TEMP, "r")
    if rf then index = tonumber(rf:read("*l")) or 0; rf:close() end
    index = (index + 1) % #files
    local wf = io.open(TEMP, "w")
    if wf then wf:write(tostring(index)); wf:close() end
    os.execute('"' .. scripts .. '/wall" "' .. files[index + 1] .. '"')
    os.exit(0)
elseif mode == "arrow-icon" then
    while true do
        print(toolbar_expanded() and "" or "")
        io.flush()
        os.execute("sleep " .. COOLDOWN)
    end
elseif mode == "ss-icon" then
    while true do
        print(toolbar_expanded() and "" or "")
        io.flush()
        os.execute("sleep " .. COOLDOWN)
    end
else
    while true do
        print(toolbar_expanded() and "     " or "")
        io.flush()
        os.execute("sleep " .. COOLDOWN)
    end
end
