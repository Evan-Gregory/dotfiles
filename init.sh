#!/usr/bin/env bash
# ~/dotfiles bootstrap / initialization.
#
# Idempotent — safe to re-run. Add further init steps as functions and call them
# from main() at the bottom.
#
# Current steps:
#   - build + install hyprutils (vendored source clone in ./hyprutils) to /usr.
#     Required to build Hyprland ecosystem tools from source (hyprpicker etc.).
#   - build + install the standalone Quickshell audio-visualiser Cava plugin
#     (module URI "Cava") onto the Qt6 QML import path. Then launch the shell
#     with:  qs -p ~/dotfiles/quickshell/visualiser
#   - install the hyprland-session.target systemd user unit so
#     xdg-desktop-portal can activate (needed for browser/OBS screen sharing).
#     See hypr/PORTAL-SESSION.md for the full rationale.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
STATE_LOG="$HOME/.local/state/dotfiles/init.log"
mkdir -p "$(dirname "$STATE_LOG")"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mXX\033[0m %s\n' "$*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

# ── hyprutils (Hyprland ecosystem base library) ─────────────────────────────
# Built from the vendored clone in ./hyprutils and installed to /usr(/lib64).
# hyprpicker (and other Hyprland tools built from source) link against it.
# Don't trust pkg-config alone here: a system cleanup once deleted the .so
# files from /usr/lib64 while leaving the .pc behind, so check the actual
# library files resolve before skipping.
init_hyprutils() {
    local src_dir="$DOTFILES/hyprutils"
    local build_dir="$src_dir/build"
    local ver
    ver="$(cat "$src_dir/VERSION")"

    if [ -e /usr/lib64/libhyprutils.so ] && [ -e "/usr/lib64/libhyprutils.so.$ver" ]; then
        log "hyprutils $ver already installed — skipping"
        return 0
    fi

    require cmake
    log "Configuring + building hyprutils $ver"
    cmake -S "$src_dir" -B "$build_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build "$build_dir" -j"$(nproc)"

    log "Installing hyprutils to /usr/lib64 (sudo)"
    if sudo cmake --install "$build_dir" && sudo ldconfig; then
        log "Installed hyprutils $ver"
    else
        warn "Install failed. Run manually:  sudo cmake --install $build_dir && sudo ldconfig"
        return 1
    fi
}

# hyprshell run has no daemonize flag and blocks in the foreground, so it's
# backgrounded here (like execs.lua's nohup_append) — otherwise it would
# prevent every init step after it from ever running.
init_hyprshell() {
    if pgrep -x hyprshell >/dev/null 2>&1; then
        log "hyprshell already running — skipping"
        return 0
    fi
    log "Starting hyprshell"
    nohup hyprshell run -c "$DOTFILES/hyprshell/config.ron" >>"$STATE_LOG" 2>&1 &
    disown
}

# ── Standalone visualiser Cava plugin ───────────────────────────────────────
init_visualiser_plugin() {
    local plugin_dir="$DOTFILES/quickshell/visualiser/plugin"
    local build_dir="$plugin_dir/build"

    require cmake
    local gen=()
    command -v ninja >/dev/null 2>&1 && gen=(-G Ninja)

    log "Configuring + building visualiser Cava plugin"
    cmake -S "$plugin_dir" -B "$build_dir" "${gen[@]}"
    cmake --build "$build_dir"

    # Resolve the Qt6 QML dir so we can clear any stale copy of the module first
    # (a clean reinstall avoids orphaned .so files from earlier builds).
    local qtpaths qml_dir
    qtpaths="$(command -v qtpaths6 || command -v qtpaths || true)"
    qml_dir="$( [ -n "$qtpaths" ] && "$qtpaths" --query QT_INSTALL_QML || echo /usr/lib64/qt6/qml )"

    log "Installing plugin to $qml_dir/Cava (sudo)"
    if sudo rm -rf "$qml_dir/Cava" && sudo cmake --install "$build_dir"; then
        log "Installed. Run:  qs -p $DOTFILES/quickshell/visualiser"
    else
        warn "Install failed. Run manually:  sudo cmake --install $build_dir"
        return 1
    fi
}

# Backgrounded the same way as init_hyprshell — qs -p ... runs in the
# foreground until killed.
init_visualiser() {
    local shell_path="$DOTFILES/quickshell/visualiser"

    if pgrep -f "qs -p $shell_path" >/dev/null 2>&1; then
        log "Visualiser already running — skipping"
        return 0
    fi
    log "Starting audio visualiser"
    nohup qs -p "$shell_path" >>"$STATE_LOG" 2>&1 &
    disown
}

# ── Hypr scripts ─────────────────────────────────────────────────────────────
# git doesn't always preserve the executable bit across fresh checkouts.
init_hypr_scripts() {
    chmod +x "$DOTFILES/hypr/scripts/journal.sh"
}

# ── Unified Quickshell shell (overlays; pure QML, no build) ─────────────────
# Hosts the extracted, dependency-free components (wallpaper picker now; lock and
# app launcher next). Nothing to compile — just make helpers executable and make
# sure a colour scheme is selected.
init_shell() {
    local shell_dir="$DOTFILES/quickshell"

    log "Preparing unified shell (pure QML, no build)"
    chmod +x "$shell_dir"/caching.sh \
             "$shell_dir"/wallpaper/*.sh "$shell_dir"/wallpaper/*.py \
             "$shell_dir"/applauncher/*.py \
             "$shell_dir"/lock/*.sh \
             "$shell_dir"/colors/*.sh 2>/dev/null || true

    # git preserves the symlink, but be defensive on fresh/edge checkouts.
    if [ ! -e "$shell_dir/colors/current.json" ]; then
        ln -sfn dracula.json "$shell_dir/colors/current.json"
        log "Selected default colour scheme -> dracula"
    fi

    # The settings app renders every icon from a vendored Material Symbols
    # variable font (loaded via FontLoader, not a system install). Warn loudly
    # if it went missing — the UI would silently show tofu boxes otherwise.
    if [ ! -f "$shell_dir/settings/assets/MaterialSymbolsRounded.ttf" ]; then
        log "WARNING: settings/assets/MaterialSymbolsRounded.ttf missing — settings icons will not render"
    fi

    log "Shell ready. Launch:        qs -p $shell_dir/shell.qml"
    log "  Toggle wallpaper picker:  qs -p $shell_dir/shell.qml ipc call shell wallpaper"
    log "  Toggle app launcher:      qs -p $shell_dir/shell.qml ipc call shell launcher"
    log "  Toggle settings panel:    qs -p $shell_dir/shell.qml ipc call shell settings"
    log "  Lock screen (hypridle):   qs -p $shell_dir/Lock.qml"
    log "  Switch colour scheme:     $shell_dir/colors/set-scheme.sh <name>"
}

# ── Portal session integration ──────────────────────────────────────────────
# xdg-desktop-portal.service has `Requisite=graphical-session.target`, so it
# refuses to activate until that target is active. Launched bare from a TTY (via
# greetd), Hyprland never brings the target up, so portal-based screen sharing
# (Firefox/Chromium/OBS ScreenCast) silently fails. The fix is a session unit
# that BindsTo graphical-session.target; hypr/autostart starts it after pushing
# the Wayland env into systemd/D-Bus. Here we just install the tracked unit into
# the systemd user directory (symlinked, matching symlink.sh's philosophy) and
# reload. See hypr/PORTAL-SESSION.md for the full write-up.
init_portal_session() {
    local unit=hyprland-session.target
    local src="$DOTFILES/hypr/systemd/$unit"
    local dest_dir="$HOME/.config/systemd/user"
    local dest="$dest_dir/$unit"

    mkdir -p "$dest_dir"
    if [ "$(readlink -f "$dest" 2>/dev/null)" = "$src" ]; then
        log "portal session unit ($unit) already linked — skipping"
        return 0
    fi

    log "Installing $unit -> $dest"
    ln -sfn "$src" "$dest"
    # daemon-reload needs a reachable user manager; skip quietly if we're not in
    # a graphical/user-bus context (e.g. running init.sh over plain SSH).
    if systemctl --user daemon-reload 2>/dev/null; then
        log "systemd user daemon reloaded"
    else
        warn "Could not reload systemd user daemon now; it will pick up $unit on next login."
    fi
}

main() {
    log "Bootstrapping dotfiles from $DOTFILES"
    init_hyprutils
    init_hyprshell
    init_visualiser_plugin
    init_visualiser
    init_hypr_scripts
    init_shell
    init_portal_session
    log "Done."
}

main "$@"
