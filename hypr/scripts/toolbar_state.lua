#!/usr/bin/env lua
local LOCK = "/tmp/expand_toolbar.lock"
local f = io.open(LOCK, "r")
if f then
    f:close()
    os.exit(0)
else
    os.exit(1)
end
