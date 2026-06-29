#!/usr/bin/env lua
local LOCK = "/tmp/expand_toolbar.lock"
local f = io.open(LOCK, "r")
if f then
    f:close()
    os.remove(LOCK)
    print("expand")
else
    io.open(LOCK, "w"):close()
    print("collapse")
end
