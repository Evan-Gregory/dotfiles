#!/usr/bin/env lua
local HOME = os.getenv("HOME")
os.execute(
    'nohup waybar'
    .. ' -c "' .. HOME .. '/.config/hypr/component/waybar/config"'
    .. ' -s "' .. HOME .. '/.config/hypr/component/waybar/style.css"'
    .. ' &'
)
