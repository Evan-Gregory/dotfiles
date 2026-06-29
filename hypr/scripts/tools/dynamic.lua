#!/usr/bin/env lua
-- Waybar custom module: interleaves media info from waybar-mpris with
-- notification banners from dunst (written by tools/notif.lua).
-- Runs as a long-lived process; output is consumed by tools/start_dyn.lua.
local HOME       = os.getenv("HOME")
local OUT        = HOME .. "/.config/hypr/store/dynamic_out.txt"
local NOTIF_FILE = HOME .. "/.config/hypr/store/latest_notif"
local NOTIF_SECS = 3  -- how long to show a notification

local function write_out(json)
    local f = io.open(OUT, "w")
    if f then f:write(json); f:close() end
end

-- Read the key=value notif file written by tools/notif.lua
local function read_notif()
    local f = io.open(NOTIF_FILE, "r")
    if not f then return nil end
    local dat = {}
    for line in f:lines() do
        local k, v = line:match("^([^=]+)=(.*)$")
        if k then dat[k] = v end
    end
    f:close()
    return dat
end

local function urgency_class(raw)
    if raw == "CRITICAL" then return "critical"
    elseif raw == "NORMAL" then return "normal"
    else return "low" end
end

-- Escape double-quotes for embedding in JSON strings
local function json_esc(s)
    return (s or ""):gsub('"', '\\"'):gsub("\n", "\\n")
end

write_out('{"class":"none","text":""}')

local prev_notif_id = nil
local notif_until   = 0  -- os.time() deadline for showing notification

local mpris = io.popen("waybar-mpris --position --autofocus")
if not mpris then
    io.stderr:write("dynamic.lua: could not start waybar-mpris\n")
    os.exit(1)
end

for line in mpris:lines() do
    local now = os.time()

    -- Check for a new notification
    local notif = read_notif()
    local nid   = notif and notif.DUNST_ID or nil
    if notif and nid ~= prev_notif_id and nid ~= "" then
        prev_notif_id = nid
        local text = "[" .. (notif.DUNST_APP_NAME or "") .. "]   " .. (notif.DUNST_SUMMARY or "")
        write_out(
            '{"class":"' .. urgency_class(notif.DUNST_URGENCY) .. '",'
            .. '"text":"' .. json_esc(text) .. '",'
            .. '"tooltip":"notification"}'
        )
        notif_until = now + NOTIF_SECS
    end

    if now < notif_until then
        -- Hold notification display; skip media output this tick
    else
        if notif_until ~= 0 then
            write_out('{"class":"none","text":""}')
            notif_until = 0
        end
        -- Extract text field from waybar-mpris JSON line
        local text = line:match('"text"%s*:%s*"(.-[^\\])"')
        if text then
            -- Strip non-breaking spaces and bullet separators
            text = text:gsub("\xc2\xa0", ""):gsub("\xe2\x80\xa2", "")
            write_out('{"class":"media","text":"' .. json_esc(text) .. '"}')
        else
            write_out('{"class":"none","text":""}')
        end
    end
end

mpris:close()
