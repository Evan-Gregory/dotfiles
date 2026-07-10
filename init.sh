#!/usr/bin/env bash
# ~/dotfiles bootstrap / initialization.
#
# Idempotent — safe to re-run. Add further init steps as functions and call them
# from main() at the bottom.
#
# Current steps:
#   - build + install the standalone Quickshell audio-visualiser Cava plugin
#     (module URI "Cava") onto the Qt6 QML import path. Then launch the shell
#     with:  qs -p ~/dotfiles/quickshell/visualiser

set -euo pipefail

DOTFILES="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mXX\033[0m %s\n' "$*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

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

main() {
    log "Bootstrapping dotfiles from $DOTFILES"
    init_visualiser_plugin
    log "Done."
}

main "$@"
