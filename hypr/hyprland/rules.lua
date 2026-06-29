-- Picture in picture
hl.window_rule({ match = { title = "^(Picture in picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture in picture)$" }, pin   = true })

-- kitty variants
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, center = true })
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, size   = { 800, 500 } })
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, float  = true })
hl.window_rule({ match = { title = "^(all_is_kitty)$" }, animation = "slide" })
hl.window_rule({ match = { title = "^(all_is_kitty)$" }, float  = true })
hl.window_rule({ match = { title = "^(kitty)$"        }, tile   = true })

-- Blueman Manager
hl.window_rule({ match = { class = "blueman-manager" }, float  = true })
hl.window_rule({ match = { class = "blueman-manager" }, size   = { 800, 600 } })
hl.window_rule({ match = { class = "blueman-manager" }, center = true })

-- Pavucontrol
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, float  = true })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, size   = { 700, 600 } })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, center = true })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, pin    = true })

-- Nautilus
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float  = true })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, center = true })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, size   = { 1200, 800 } })

-- Cava
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, float  = true })
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, center = true })
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, size   = { 1200, 500 } })

-- Journal
hl.window_rule({ match = { title = "^(fly_is_journal)$" }, float  = true })
hl.window_rule({ match = { title = "^(fly_is_journal)$" }, center = true })
hl.window_rule({ match = { title = "^(fly_is_journal)$" }, size   = { 1200, 800 } })

-- Mail (Vivaldi PWA)
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, float  = true })
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, size   = { 1400, 1000 } })
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, center = true })

-- Clock
hl.window_rule({ match = { title = "^(clock_is_kitty)$" }, float = true })
hl.window_rule({ match = { title = "^(clock_is_kitty)$" }, size  = { 418, 180 } })

-- 1Password
hl.window_rule({ match = { class = "1Password" }, float  = true })
hl.window_rule({ match = { class = "1Password" }, size   = { 1200, 600 } })
hl.window_rule({ match = { class = "1Password" }, center = true })
hl.window_rule({ match = { class = "1Password" }, pin    = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "waybar" }, blur         = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_zero  = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.045 })
