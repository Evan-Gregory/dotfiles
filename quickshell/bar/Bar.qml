pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property ShellScreen screen

    screen: root.screen
    width:  68
    color:  "transparent"

    // Left-side vertical panel, full height
    anchors.left:   true
    anchors.top:    true
    anchors.bottom: true
    exclusiveZone:  width

    WlrLayershell.layer: WlrLayer.Top

    // ── Background surface ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.118, 0.118, 0.180, 0.92)  // #1e1e2e @ 92%

        // Right border — subtle blue line
        Rectangle {
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: Qt.rgba(0.537, 0.706, 0.980, 0.18)  // blue @ 18%
        }

        // ── Main layout ──────────────────────────────────────────────────
        ColumnLayout {
            anchors {
                fill:           parent
                topMargin:      6
                bottomMargin:   6
                leftMargin:     4
                rightMargin:    4
            }
            spacing: 4

            // ── TOP: launcher + workspaces ───────────────────────────────
            AppMenuWidget   { Layout.alignment: Qt.AlignHCenter }
            WorkspacesWidget {
                Layout.alignment: Qt.AlignHCenter
                screen: root.screen
            }

            // ── SPACER ───────────────────────────────────────────────────
            Item { Layout.fillHeight: true }

            // ── CENTER: clock ─────────────────────────────────────────────
            ClockWidget { Layout.alignment: Qt.AlignHCenter }

            // ── SPACER ───────────────────────────────────────────────────
            Item { Layout.fillHeight: true }

            // ── BOTTOM: system status ────────────────────────────────────
            SysStatsWidget { Layout.alignment: Qt.AlignHCenter }
            NetworkWidget  { Layout.alignment: Qt.AlignHCenter }
            AudioWidget    { Layout.alignment: Qt.AlignHCenter }
            BatteryWidget  { Layout.alignment: Qt.AlignHCenter }

            Item { height: 2 }
        }
    }
}
