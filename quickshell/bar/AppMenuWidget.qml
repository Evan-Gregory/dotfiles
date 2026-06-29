import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root

    width:  58
    height: 36
    radius: 10
    color:  ma.containsMouse ? "#313244" : "#1e1e2e"
    border.width: 2
    border.color: ma.containsMouse ? "#cba6f7" : "#45475a"

    Behavior on color        { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text:  "Apps"
        color: "#cba6f7"
        font.pixelSize: 11
        font.weight: Font.Bold
    }

    MouseArea {
        id: ma
        anchors.fill:  parent
        hoverEnabled:  true
        onClicked: Quickshell.execDetached(["bash", "-c", "sleep 0.1; pkill wofi 2>/dev/null; wofi --show drun"])
    }
}
