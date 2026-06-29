#!/usr/bin/env lua
-- Dunst action hook: called by dunst after displaying a notification.
-- Writes notification data to a file for tools/dynamic.lua to consume.
local HOME = os.getenv("HOME")
local fields = {
    "DUNST_APP_NAME", "DUNST_SUMMARY", "DUNST_BODY",
    "DUNST_ICON_PATH", "DUNST_URGENCY", "DUNST_ID",
    "DUNST_PROGRESS", "DUNST_CATEGORY", "DUNST_STACK_TAG",
    "DUNST_URLS", "DUNST_TIMEOUT", "DUNST_TIMESTAMP",
    "DUNST_DESKTOP_ENTRY",
}
local f = io.open(HOME .. "/.config/hypr/store/latest_notif", "w")
if f then
    for _, k in ipairs(fields) do
        f:write(k .. "=" .. (os.getenv(k) or "") .. "\n")
    end
    f:close()
end
