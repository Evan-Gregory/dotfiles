#!/usr/bin/env lua
-- Waybar custom module wrapper: starts dynamic.lua in background,
-- then streams its output file to stdout at 0.5s intervals.
local HOME     = os.getenv("HOME")
local scripts  = HOME .. "/.config/hypr/scripts"
local out_file = HOME .. "/.config/hypr/store/dynamic_out.txt"

os.execute('"' .. scripts .. '/tools/dynamic" &')

while true do
    local f = io.open(out_file, "r")
    if f then
        local content = f:read("*a"):gsub("^%s+", ""):gsub("%s+$", "")
        f:close()
        if content ~= "" then
            print(content)
            io.flush()
        end
    end
    os.execute("sleep 0.5")
end
