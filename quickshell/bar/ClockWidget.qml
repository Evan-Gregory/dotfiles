import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    width:  58
    implicitHeight: col.implicitHeight + 18
    radius: 10
    color:  "#1e1e2e"
    border.width: 2
    border.color: Qt.rgba(0.537, 0.706, 0.980, 0.18)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  clock.hours.toString().padStart(2, '0')
            color: "#cba6f7"
            font.pixelSize: 17
            font.weight:    Font.Bold
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 28
            height: 1
            color: "#45475a"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  clock.minutes.toString().padStart(2, '0')
            color: "#cdd6f4"
            font.pixelSize: 17
            font.weight:    Font.Bold
        }
    }
}
