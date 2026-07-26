-- Picture in picture
hl.window_rule({ match = { title = "^(Picture in picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture in picture)$" }, pin = true })

-- kitty variants
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, center = true })
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, size = { 800, 500 } })
hl.window_rule({ match = { title = "^(fly_is_kitty)$" }, float = true })
hl.window_rule({ match = { title = "^(all_is_kitty)$" }, animation = "slide" })
hl.window_rule({ match = { title = "^(all_is_kitty)$" }, float = true })
hl.window_rule({ match = { title = "^(kitty)$" }, tile = true })

-- Blueman Manager
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, size = { 800, 600 } })
hl.window_rule({ match = { class = "blueman-manager" }, center = true })

-- Pavucontrol
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, float = true })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, size = { 700, 600 } })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, center = true })
hl.window_rule({ match = { class = ".*org.pulseaudio.pavucontrol.*" }, pin = true })

-- Nautilus
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, center = true })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, size = { 1200, 800 } })

-- Cava
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, float = true })
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, center = true })
hl.window_rule({ match = { title = "^(fly_is_cava)$" }, size = { 1200, 500 } })

-- Journal
hl.window_rule({ match = { title = "^(fly_is_journal)$" }, float = true })
hl.window_rule({ match = { title = "^(fly_is_journal)$" }, center = true })
-- hl.window_rule({ match = { title = "^(fly_is_journal)$" }, size = { "(monitor_w * 0.9)", "(monitor_h * 0.9)" } })

hl.window_rule({
	match = { class = "flameshot" },
	no_anim = true,
	pin = true,
	float = true,
	decorate = false,
	no_blur = true,
	no_shadow = true,
})
-- Flameshot v14 captures via the xdg-desktop-portal Screenshot API and positions
-- its fullscreen overlay itself; these move rules just anchor the overlay window.
hl.window_rule({
	match = { class = "flameshot", title = "flameshot" },
	move = { 0, 0 },
})
hl.window_rule({
	match = { class = "flameshot", title = "flameshot-pin" },
	move = { "cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)" },
})

-- Mail (Vivaldi PWA)
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, float = true })
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, size = { 1400, 1000 } })
hl.window_rule({ match = { class = "vivaldi-pkooggnaalmfkidjmlhoelhdllpphaga-Default" }, center = true })

-- Clock
hl.window_rule({ match = { title = "^(clock_is_kitty)$" }, float = true })
hl.window_rule({ match = { title = "^(clock_is_kitty)$" }, size = { 418, 180 } })

-- 1Password
hl.window_rule({ match = { class = "1Password" }, float = true })
hl.window_rule({ match = { class = "1Password" }, size = { 1200, 600 } })
hl.window_rule({ match = { class = "1Password" }, center = true })
hl.window_rule({ match = { class = "1Password" }, pin = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
-- hl.layer_rule({ match = { namespace = "waybar" }, ignore_zero  = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.045 })

-- Quickshell overlays (launcher, wallpaper picker) fade in/out instead of
-- using the global layersIn/layersOut slide animation.
hl.layer_rule({ match = { namespace = "quickshell" }, animation = "fadeLayers" })

-- ./dotfiles/hypr/scripts/journal.sh;
hl.workspace_rule({
	workspace = "special:journal",
	on_created_empty = HOME
		.. "/dotfiles/hypr/scripts/journal.sh; kitty --title kitty_is_journal --hold nvim ~/wiki/journal/$(date '+%Y-%m-%d').md",
	gaps_out = 25,
	animation = "fade",
})
hl.workspace_rule({
	workspace = "special:teams",
	on_created_empty = "teams-for-linux",
	gaps_out = 25,
	animation = "fade",
})
