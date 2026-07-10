pragma ComponentBehavior: Bound

import Quickshell.Widgets
import QtQuick

// Desktop audio visualiser: full-width CAVA bars anchored to the bottom of the
// screen. Fully self-contained — every dependency is inlined below; the only
// external input is `cava` (a CavaProvider from the Cava plugin).
Item {
    id: root

    // Cava data source (CavaProvider from the `Cava` plugin). `cava.values` is
    // an array of `cava.bars` magnitudes in 0..1.
    required property var cava

    // ── Tweakables (baked constants) ──
    property int barCount: cava ? cava.bars : 0         // number of bars (matches the provider)
    property int spacingPx: 14                          // gap between bars (px)
    property int topRadius: 120                         // top-corner radius (clamps to half-width → pill tops)
    property real maxHeightFraction: 0.4                // bars peak at 40% of screen height
    property int leftMargin: 0                          // reserve space at the left edge (px)
    property color colorTop: "#BD93F9"                  // gradient top    (M3 primary)
    property color colorBottom: "#9D73D9"               // gradient bottom (M3 inverse-primary)
    property real fillOpacity: 0.7

    Item {
        id: content

        anchors.fill: parent
        anchors.leftMargin: root.leftMargin

        Repeater {
            model: root.barCount

            ClippingRectangle {
                id: bar

                required property int modelData
                property real value: Math.max(0, Math.min(1, root.cava?.values[modelData] ?? 0))

                clip: true
                color: "transparent"

                x: modelData * (content.width / root.barCount)
                implicitWidth: content.width / root.barCount - root.spacingPx

                y: content.height - height
                implicitHeight: bar.value * content.height * root.maxHeightFraction

                topLeftRadius: root.topRadius
                topRightRadius: root.topRadius

                // Fixed-height gradient rect that the bar clips: as the bar
                // grows it *reveals* more of the gradient from the bottom up
                // (colour at a given screen-y stays constant) rather than
                // stretching it.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    y: parent.height - height
                    implicitHeight: content.height * root.maxHeightFraction

                    topLeftRadius: parent.topLeftRadius
                    topRightRadius: parent.topRightRadius

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0
                            color: Qt.rgba(root.colorTop.r, root.colorTop.g, root.colorTop.b, root.fillOpacity)
                            Behavior on color {
                                CAnim {}
                            }
                        }
                        GradientStop {
                            position: 1
                            color: Qt.rgba(root.colorBottom.r, root.colorBottom.g, root.colorBottom.b, root.fillOpacity)
                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }

                Behavior on value {
                    Anim {
                        duration: 200
                    }
                }
            }
        }
    }

    // Inlined animation helpers (Material 3 "standard" easing).
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
    }
    component CAnim: ColorAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
    }
}
