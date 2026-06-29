pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property ShellScreen screen

    width:  58
    // height is implicit from column
    implicitHeight: col.implicitHeight + 10
    radius: 12
    color: "transparent"
    border.width: 2
    border.color: "#89b4fa"

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: [1, 2, 3, 4, 5]

            Rectangle {
                id: wsBtn
                required property int modelData

                readonly property bool active:   Hyprland.focusedWorkspace?.id === modelData
                readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === modelData)

                width:  46
                height: 26
                radius: 7

                color: wsBtn.active
                    ? "#cba6f7"
                    : wsBtn.occupied
                        ? Qt.rgba(0.537, 0.706, 0.980, 0.18)
                        : "#1e1e2e"

                Behavior on color { ColorAnimation { duration: 180 } }

                Text {
                    anchors.centerIn: parent
                    text:  String(wsBtn.modelData)
                    color: wsBtn.active ? "#1e1e2e" : "#cdd6f4"
                    font.pixelSize: 12
                    font.weight:    Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:    Hyprland.dispatch("workspace " + wsBtn.modelData)
                }
            }
        }
    }
}
