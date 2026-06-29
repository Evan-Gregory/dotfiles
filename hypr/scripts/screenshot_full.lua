#!/usr/bin/env lua
os.execute("grim - | wl-copy")
os.execute('notify-send "Screenshot copied to clipboard" -a "ss"')
