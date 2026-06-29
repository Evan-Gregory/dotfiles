hl.env("WLR_DRM_DEVICES", "/dev/dri/card1")

hl.env("HYPRCURSOR_THEME", "catppuccin-frappe-mauve-cursors")
hl.env("HYPRCURSOR_SIZE", "20")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QSG_RHI_BACKEND", "vulkan")
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
