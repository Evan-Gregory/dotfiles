//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "bar"
import "wallpaper"

ShellRoot {
    id: root

    property bool wallpaperPickerVisible: false

    // ── One bar per connected screen ─────────────────────────────────────
    Variants {
        model: Quickshell.screens
        Bar {
            id: _bar
            required property ShellScreen modelData
            screen: modelData
        }
    }

    // ── Wallpaper picker overlay (primary screen) ────────────────────────
    PanelWindow {
        id: wallpaperWindow
        screen: Quickshell.screens[0]
        visible: root.wallpaperPickerVisible
        color: "transparent"

        anchors.left:   true
        anchors.right:  true
        anchors.top:    true
        anchors.bottom: true

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        // Translucent backdrop — click to dismiss
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: root.wallpaperPickerVisible = false
            }
        }

        // The picker itself, vertically centered
        WallpaperPicker {
            id: picker
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            height: Math.round(Math.min(parent.height * 0.62, 680))
        }

        Shortcut {
            sequence: "Escape"
            onActivated: root.wallpaperPickerVisible = false
        }
    }

    // ── IPC — trigger from keybinds ─────────────────────────────────────
    // Usage: quickshell ipc call shell wallpaper
    //        quickshell ipc call shell reload
    IpcHandler {
        target: "shell"
        function wallpaper(): void {
            root.wallpaperPickerVisible = !root.wallpaperPickerVisible;
        }
        function reload(): void {
            Qt.quit();
        }
    }
}
