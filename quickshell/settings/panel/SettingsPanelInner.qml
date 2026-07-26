pragma ComponentBehavior: Bound

import qs.settings.components
import qs.settings.components.controls
import qs.settings.services
import qs.settings.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property ShellScreen screen: Quickshell.screens[0]
    // floating stays permanently false — this shell has no floating-window
    // mode (WindowFactory/WindowTitle were dropped with it), but keeping the
    // property/alias plumbing as an inert constant avoids touching every
    // ternary below that already branches on it correctly for the non-
    // floating case.
    readonly property int rounding: floating ? 0 : Appearance.rounding.normal

    // Fixed panel proportions. Not user-configurable — this is chrome
    // sizing, not shell config.
    readonly property real sizeRatio: 16 / 9
    readonly property real sizeHeightMult: 0.7

    property alias floating: session.floating
    property alias active: session.active
    property alias navExpanded: session.navExpanded

    signal closeRequested

    readonly property Session session: Session {
        id: session

        root: root
    }

    implicitWidth: implicitHeight * root.sizeRatio
    implicitHeight: screen.height * root.sizeHeightMult

    GridLayout {
        anchors.fill: parent

        rowSpacing: 0
        columnSpacing: 0
        rows: 1
        columns: 2

        StyledRect {
            Layout.fillHeight: true

            topLeftRadius: root.rounding
            bottomLeftRadius: root.rounding
            implicitWidth: navRail.implicitWidth
            color: Colours.tPalette.m3surfaceContainer

            CustomMouseArea {
                anchors.fill: parent

                function onWheel(event: WheelEvent): void {
                    // Prevent tab switching during initial opening animation to avoid blank pages
                    if (!panes.initialOpeningComplete) {
                        return;
                    }

                    if (event.angleDelta.y < 0)
                        root.session.activeIndex = Math.min(root.session.activeIndex + 1, root.session.panes.length - 1);
                    else if (event.angleDelta.y > 0)
                        root.session.activeIndex = Math.max(root.session.activeIndex - 1, 0);
                }
            }

            NavRail {
                id: navRail

                screen: root.screen
                session: root.session
                initialOpeningComplete: root.initialOpeningComplete
            }
        }

        Panes {
            id: panes

            Layout.fillWidth: true
            Layout.fillHeight: true

            topRightRadius: root.rounding
            bottomRightRadius: root.rounding
            session: root.session
        }
    }

    IconButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Appearance.padding.normal
        icon: "close"
        type: IconButton.Text
        onClicked: root.closeRequested()
    }

    readonly property bool initialOpeningComplete: panes.initialOpeningComplete
}
