import qs.settings.panel
import Quickshell
import QtQuick

// Entry point loaded by shell.qml's settings overlay (Loader { source:
// "settings/SettingsPanel.qml" }). Thin wrapper so the host's dismiss
// pattern (closeRequested signal) doesn't need to know about the panel's
// internal screen requirement.
Item {
    id: root

    property ShellScreen screen: Quickshell.screens[0]

    signal closeRequested

    implicitWidth: inner.implicitWidth
    implicitHeight: inner.implicitHeight

    SettingsPanelInner {
        id: inner
        screen: root.screen
        onCloseRequested: root.closeRequested()
    }
}
