pragma Singleton

import Quickshell
import QtQuick

// Visual metrics for the settings app: corner rounding, spacing, padding,
// fonts and animation parameters. Values scale with Config.uiScale so the
// settings window obeys the UI-scale slider it hosts.
//
// The icon font is vendored (assets/MaterialSymbolsRounded.ttf) and loaded
// here rather than assumed installed; MaterialIcon renders glyphs by
// ligature name with variable axes (FILL/GRAD/opsz/wght), which needs the
// variable font.
Singleton {
    id: root

    readonly property real scale: Config.uiScale

    readonly property FontLoader materialFont: FontLoader {
        source: Qt.resolvedUrl("../assets/MaterialSymbolsRounded.ttf")
    }

    readonly property QtObject rounding: QtObject {
        // Rounding multiplier; 0 means fully square corners (checked by
        // components to pick square line caps).
        readonly property real scale: 1
        readonly property int small: Math.round(12 * root.scale)
        readonly property int normal: Math.round(17 * root.scale)
        readonly property int large: Math.round(25 * root.scale)
        readonly property int full: 1000
    }

    readonly property QtObject spacing: QtObject {
        readonly property int small: Math.round(7 * root.scale)
        readonly property int smaller: Math.round(10 * root.scale)
        readonly property int normal: Math.round(12 * root.scale)
        readonly property int larger: Math.round(15 * root.scale)
        readonly property int large: Math.round(20 * root.scale)
    }

    readonly property QtObject padding: QtObject {
        readonly property int small: Math.round(5 * root.scale)
        readonly property int smaller: Math.round(7 * root.scale)
        readonly property int normal: Math.round(10 * root.scale)
        readonly property int larger: Math.round(12 * root.scale)
        readonly property int large: Math.round(15 * root.scale)
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string sans: "JetBrains Mono"
            readonly property string mono: "Iosevka Nerd Font"
            readonly property string material: root.materialFont.status === FontLoader.Ready ? root.materialFont.name : "Material Symbols Rounded"
        }

        readonly property QtObject size: QtObject {
            readonly property int small: Math.round(11 * root.scale)
            readonly property int smaller: Math.round(12 * root.scale)
            readonly property int normal: Math.round(13 * root.scale)
            readonly property int larger: Math.round(15 * root.scale)
            readonly property int large: Math.round(18 * root.scale)
            readonly property int extraLarge: Math.round(28 * root.scale)
        }
    }

    readonly property QtObject anim: QtObject {
        readonly property QtObject durations: QtObject {
            readonly property real scale: 1
            readonly property int small: 200
            readonly property int normal: 400
            readonly property int large: 600
            readonly property int extraLarge: 1000
            readonly property int expressiveFastSpatial: 350
            readonly property int expressiveDefaultSpatial: 500
            readonly property int expressiveEffects: 200
        }

        readonly property QtObject curves: QtObject {
            readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
            readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
            readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
            readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
            readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
        }
    }

    readonly property QtObject transparency: QtObject {
        readonly property bool enabled: false
        readonly property real base: 0.85
        readonly property real layers: 0.4
    }
}
