//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "wallpaper"
import "applauncher"
// Module registration bootstrap: qs.settings.* is referenced by
// settings/SettingsPanel.qml (dynamically loaded below) and by
// WallpaperPicker.qml's Config.wallpaperDir — both resolve only because a
// static import here registers the module for the whole config root.
import qs.settings.config
import qs.settings.services
import qs.settings.utils
import qs.settings.components
import qs.settings.components.controls
import qs.settings.components.containers
import qs.settings.components.effects
import qs.settings.panel

// Unified shell: a background daemon that hosts on-demand overlays toggled via
// IPC. Fully self-contained — depends on no external shell project. The prior
// bar/ is incomplete (missing BatteryWidget) and is not wired in. The lock
// screen (Lock.qml) is launched separately by hypridle.
ShellRoot {
    id: root

    property bool wallpaperPickerVisible: false
    property bool launcherVisible: false
    property bool settingsVisible: false

    // Screen each overlay opens on — captured at toggle-open time (see the
    // IpcHandler below) so an overlay doesn't jump mid-use if focus changes
    // elsewhere while it's open.
    property var wallpaperScreen: Quickshell.screens[0]
    property var launcherScreen: Quickshell.screens[0]
    property var settingsScreen: Quickshell.screens[0]

    // Resolves Hyprland's currently-focused monitor to its matching
    // Quickshell ShellScreen (matched by output name, e.g. "eDP-1").
    function focusedScreen() {
        const mon = Hyprland.focusedMonitor;
        if (mon) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === mon.name)
                    return Quickshell.screens[i];
            }
        }
        return Quickshell.screens[0];
    }

    // ── Wallpaper picker overlay (active monitor) ────────────────────────
    PanelWindow {
        id: wallpaperWindow
        screen: root.wallpaperScreen
        visible: root.wallpaperPickerVisible
        color: "transparent"

        anchors.left:   true
        anchors.right:  true
        anchors.top:    true
        anchors.bottom: true

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        // Exclusive so the picker's search box / keyboard nav receive input.
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Translucent backdrop — click to dismiss
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: root.wallpaperPickerVisible = false
            }
        }

        // The picker itself, full-width strip, vertically centered.
        WallpaperPicker {
            id: picker
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            height: Math.round(Math.min(parent.height * 0.62, 680))

            // Escape (while not searching) / two-stage dismiss from the picker.
            onCloseRequested: root.wallpaperPickerVisible = false
        }
    }

    // ── App launcher overlay (active monitor) ─────────────────────────────
    PanelWindow {
        id: launcherWindow
        screen: root.launcherScreen
        visible: root.launcherVisible
        color: "transparent"

        anchors.left:   true
        anchors.right:  true
        anchors.top:    true
        anchors.bottom: true

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: root.launcherVisible = false
            }
        }

        // Centered box; the launcher anchors its content to the box top and
        // grows/shrinks downward with the result count.
        AppLauncher {
            id: launcher
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            width:  Math.round(Math.min(parent.width * 0.5, 820))
            height: Math.round(Math.min(parent.height * 0.8, 760))

            // Reset to a clean state each time the overlay opens.
            onVisibleChanged: if (visible) forceActiveFocus()

            onCloseRequested: root.launcherVisible = false
        }
    }

    // ── Settings overlay (active monitor) ────────────────────────────────
    PanelWindow {
        id: settingsWindow
        screen: root.settingsScreen
        visible: root.settingsVisible
        color: "transparent"

        anchors.left:   true
        anchors.right:  true
        anchors.top:    true
        anchors.bottom: true

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: root.settingsVisible = false
            }
        }

        // Loaded by path (not inlined) so a broken settings/ tree degrades
        // to a logged error instead of taking the whole daemon — and with
        // it the wallpaper picker and launcher — down.
        Loader {
            id: settingsLoader
            anchors.centerIn: parent
            active: root.settingsVisible
            source: "settings/SettingsPanel.qml"

            onLoaded: item.screen = settingsWindow.screen

            onStatusChanged: {
                if (status === Loader.Error)
                    console.warn("SettingsPanel failed to load:", settingsLoader.sourceComponent);
            }

            Connections {
                target: settingsLoader.item
                ignoreUnknownSignals: true
                function onCloseRequested(): void {
                    root.settingsVisible = false;
                }
            }
        }

        Shortcut {
            enabled: root.settingsVisible
            sequence: "Escape"
            onActivated: root.settingsVisible = false
        }
    }

    // ── IPC — trigger from keybinds ─────────────────────────────────────
    // Usage: quickshell ipc call shell wallpaper
    //        quickshell ipc call shell launcher
    //        quickshell ipc call shell settings
    //        quickshell ipc call shell reload
    IpcHandler {
        target: "shell"
        function wallpaper(): void {
            if (!root.wallpaperPickerVisible)
                root.wallpaperScreen = root.focusedScreen();
            root.wallpaperPickerVisible = !root.wallpaperPickerVisible;
        }
        function launcher(): void {
            if (!root.launcherVisible)
                root.launcherScreen = root.focusedScreen();
            root.launcherVisible = !root.launcherVisible;
        }
        function settings(): void {
            if (!root.settingsVisible)
                root.settingsScreen = root.focusedScreen();
            root.settingsVisible = !root.settingsVisible;
        }
        function reload(): void {
            Qt.quit();
        }
    }
}
