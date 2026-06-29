hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 4,
        border_size = 2,
        layout = "dwindle",
        resize_on_border = false,
        extend_border_grab_area = 20,
        allow_tearing = false,
        no_border_on_floating = false,
        col = {
            active_border   = "rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 45deg",
            inactive_border = "0xff45475a"
        }
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled          = true,
            size             = 1,
            passes           = 1,
            new_optimizations = true,
            ignore_opacity   = true,
            xray             = true,
            vibrancy         = 1
        },
        shadow = {
            enabled        = true,
            color          = "0x33000000",
            color_inactive = "0x22000000",
            range          = 100,
            render_power   = 5
        }
    },

    input = {
        sensitivity  = 1.0,
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false
        }
    },

    misc = {
        vfr                           = true,
        vrr                           = 1,
        animate_manual_resizes        = false,
        animate_mouse_windowdragging  = false,
        disable_hyprland_logo         = true,
        force_default_wallpaper       = 0,
        new_window_takes_over_fullscreen = 2,
        allow_session_lock_restore    = true,
        middle_click_paste            = false,
        focus_on_activate             = true,
        mouse_move_enables_dpms       = true,
        key_press_enables_dpms        = true
    },

    xwayland = {
        force_zero_scaling   = true,
        use_nearest_neighbor = true,
        enabled              = true
    },

    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false
    },

    dwindle = {
        pseudotile            = true,
        preserve_split        = true,
        split_width_multiplier = 1,
        default_split_ratio   = 1.25
    },

    master = {
        always_keep_position = true,
        orientation          = "center",
        drop_at_cursor       = true
    },

    gestures = {
        workspace_swipe         = true,
        workspace_swipe_fingers = 4
    },

    animations = {
        enabled = true
    },

    debug = {
        error_position = 1,
        disable_logs   = false
    }
})

-- Bezier curves
hl.curve("specialWorkSwitch", { type = "bezier", points = {{0.05, 0.7}, {0.1,  1   }} })
hl.curve("emphasizedAccel",   { type = "bezier", points = {{0.3,  0  }, {0.8,  0.15}} })
hl.curve("emphasizedDecel",   { type = "bezier", points = {{0.05, 0.7}, {0.1,  1   }} })
hl.curve("standard",          { type = "bezier", points = {{0.2,  0  }, {0,    1   }} })

-- Animations
hl.animation({ leaf = "layersIn",         enabled = true, speed = 5, bezier = "emphasizedDecel",   style = "slide" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 4, bezier = "emphasizedAccel",   style = "slide" })
hl.animation({ leaf = "fadeLayers",       enabled = true, speed = 5, bezier = "standard" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5, bezier = "standard" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })
hl.animation({ leaf = "fade",             enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim",          enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border",           enabled = true, speed = 6, bezier = "standard" })
