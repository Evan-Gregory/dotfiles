import ".."
import qs.settings.services
import qs.settings.config
import QtQuick

// Indeterminate spinner: a rotating arc that cyclically grows and shrinks,
// drawn with CircularProgress. Pure QML.
Item {
    id: root

    property bool running: true

    property real implicitSize: Appearance.font.size.normal * 3
    property real strokeWidth: Appearance.padding.small * 0.8
    property color fgColour: Colours.palette.m3primary
    property color bgColour: Colours.palette.m3secondaryContainer

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    opacity: running ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        Anim {}
    }

    CircularProgress {
        id: arc

        anchors.fill: parent

        strokeWidth: root.strokeWidth
        fgColour: root.fgColour
        bgColour: root.bgColour

        RotationAnimation on rotation {
            running: root.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1200
        }

        SequentialAnimation on value {
            running: root.visible
            loops: Animation.Infinite

            Anim {
                from: 0.08
                to: 0.7
                duration: 700
            }

            Anim {
                from: 0.7
                to: 0.08
                duration: 700
            }
        }
    }
}
