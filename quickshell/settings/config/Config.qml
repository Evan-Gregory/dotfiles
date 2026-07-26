pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Single persistent store for the shell's user configuration, backed by
// settings.json at the config root. Other shell components (Scaler.qml)
// watch the same file, so writes here propagate shell-wide.
//
// Saves are debounced, and the recentlySaved flag suppresses the
// watchChanges-triggered reload of our own writes (prevents reload loops).
Singleton {
    id: root

    property alias uiScale: adapter.uiScale
    property alias wallpaperDir: adapter.wallpaperDir
    property alias audio: adapter.audio
    property alias vpn: adapter.vpn

    // Debounced persist — call after mutating any property above.
    function save(): void {
        saveTimer.restart();
        recentlySaved = true;
        recentSaveCooldown.restart();
    }

    property bool recentlySaved: false

    Timer {
        id: saveTimer

        interval: 500
        onTriggered: fileView.writeAdapter()
    }

    Timer {
        id: recentSaveCooldown

        interval: 2000
        onTriggered: root.recentlySaved = false
    }

    FileView {
        id: fileView

        path: Qt.resolvedUrl("../../settings.json").toString().replace(/^file:\/\//, "")
        watchChanges: true
        onFileChanged: {
            // External edit -> reload; our own write -> adapter already current.
            if (!root.recentlySaved)
                reload();
        }

        JsonAdapter {
            id: adapter

            property real uiScale: 1.0
            property string wallpaperDir: ""
            property AudioSettings audio: AudioSettings {}
            property VpnSettings vpn: VpnSettings {}
        }
    }

    component AudioSettings: JsonObject {
        property real increment: 0.1
        property real maxVolume: 1.0
    }

    component VpnSettings: JsonObject {
        property bool enabled: false
        // Entries are either builtin provider names (strings) or objects:
        // { name, interface, enabled, connectCmd?, disconnectCmd?, displayName? }
        property list<var> provider: []
    }
}
