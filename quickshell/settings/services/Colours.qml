pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Colour service for the settings app. Reads the active scheme from
// colors/current.json (symlink managed by colors/set-scheme.sh) and exposes
// it through Material-3-style role names, which is the vocabulary the
// vendored UI components speak.
//
// The scheme file is POLLED (like Theme.qml) rather than watched: the
// symlink is repointed with ln -sfn, and a file watcher would keep the old
// target's inode and miss scheme switches entirely.
//
// Mapping rules (dark schemes):
//   surfaces    base/mantle/crust + surface0-2 by elevation
//   on-colours  text/subtext; but on-ACCENT colours are DARK (crust) because
//               the accents themselves are bright — light-on-light otherwise
//   containers  mix(accent 32%, base); on-containers mix(accent 20%, text)
//   accents     primary<-blue  secondary<-pink  tertiary<-peach
//               error<-red  success<-green
Singleton {
    id: root

    // ── semantic scheme values (defaults: Dracula, matching colors/dracula.json) ──
    property color base: "#282a36"
    property color mantle: "#21222c"
    property color crust: "#191a21"
    property color text: "#f8f8f2"
    property color subtext1: "#e2e2ec"
    property color subtext0: "#c7c8d6"
    property color surface0: "#343746"
    property color surface1: "#44475a"
    property color surface2: "#565872"
    property color overlay0: "#6272a4"
    property color overlay1: "#7a86b8"
    property color overlay2: "#939ac7"
    property color blue: "#bd93f9"
    property color pink: "#ff79c6"
    property color peach: "#ffb86c"
    property color red: "#ff5555"
    property color green: "#50fa7b"
    property color yellow: "#f1fa8c"

    property string scheme: "dracula"
    property bool light: false

    property string rawJson: ""

    readonly property string schemeFile: Qt.resolvedUrl("../../colors/current.json").toString().replace(/^file:\/\//, "")

    // Weighted blend: w of a over (1 - w) of b.
    function mix(a: color, b: color, w: real): color {
        return Qt.rgba(a.r * w + b.r * (1 - w), a.g * w + b.g * (1 - w), a.b * w + b.b * (1 - w), 1);
    }

    // Legible counterpart of an arbitrary colour.
    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    // Transparency layering — disabled in this shell; identity keeps the
    // vendored call sites working unchanged.
    function layer(c: color, l: var): color {
        return c;
    }

    readonly property M3Palette palette: M3Palette {}
    readonly property M3Palette tPalette: palette

    readonly property QtObject transparency: QtObject {
        readonly property bool enabled: false
        readonly property real base: 0.85
        readonly property real layers: 0.4
    }

    component M3Palette: QtObject {
        readonly property color m3primary_paletteKeyColor: root.blue
        readonly property color m3secondary_paletteKeyColor: root.pink
        readonly property color m3tertiary_paletteKeyColor: root.peach
        readonly property color m3neutral_paletteKeyColor: root.overlay0
        readonly property color m3neutral_variant_paletteKeyColor: root.overlay1

        readonly property color m3background: root.base
        readonly property color m3onBackground: root.text
        readonly property color m3surface: root.base
        readonly property color m3surfaceDim: root.mantle
        readonly property color m3surfaceBright: root.surface1
        readonly property color m3surfaceContainerLowest: root.crust
        readonly property color m3surfaceContainerLow: root.mantle
        readonly property color m3surfaceContainer: root.surface0
        readonly property color m3surfaceContainerHigh: root.surface1
        readonly property color m3surfaceContainerHighest: root.surface2
        readonly property color m3onSurface: root.text
        readonly property color m3surfaceVariant: root.surface1
        readonly property color m3onSurfaceVariant: root.subtext1
        readonly property color m3inverseSurface: root.text
        readonly property color m3inverseOnSurface: root.base
        readonly property color m3outline: root.overlay1
        readonly property color m3outlineVariant: root.surface2
        readonly property color m3shadow: root.crust
        readonly property color m3scrim: root.crust
        readonly property color m3surfaceTint: root.blue

        readonly property color m3primary: root.blue
        readonly property color m3onPrimary: root.crust
        readonly property color m3primaryContainer: root.mix(root.blue, root.base, 0.32)
        readonly property color m3onPrimaryContainer: root.mix(root.blue, root.text, 0.2)
        readonly property color m3inversePrimary: root.mix(root.blue, root.crust, 0.55)

        readonly property color m3secondary: root.pink
        readonly property color m3onSecondary: root.crust
        readonly property color m3secondaryContainer: root.mix(root.pink, root.base, 0.32)
        readonly property color m3onSecondaryContainer: root.mix(root.pink, root.text, 0.2)

        readonly property color m3tertiary: root.peach
        readonly property color m3onTertiary: root.crust
        readonly property color m3tertiaryContainer: root.mix(root.peach, root.base, 0.32)
        readonly property color m3onTertiaryContainer: root.mix(root.peach, root.text, 0.2)

        readonly property color m3error: root.red
        readonly property color m3onError: root.crust
        readonly property color m3errorContainer: root.mix(root.red, root.base, 0.32)
        readonly property color m3onErrorContainer: root.mix(root.red, root.text, 0.2)

        readonly property color m3success: root.green
        readonly property color m3onSuccess: root.crust
        readonly property color m3successContainer: root.mix(root.green, root.base, 0.32)
        readonly property color m3onSuccessContainer: root.mix(root.green, root.text, 0.2)

        readonly property color m3primaryFixed: root.mix(root.blue, root.text, 0.5)
        readonly property color m3primaryFixedDim: root.blue
        readonly property color m3onPrimaryFixed: root.crust
        readonly property color m3onPrimaryFixedVariant: root.mix(root.blue, root.base, 0.5)
        readonly property color m3secondaryFixed: root.mix(root.pink, root.text, 0.5)
        readonly property color m3secondaryFixedDim: root.pink
        readonly property color m3onSecondaryFixed: root.crust
        readonly property color m3onSecondaryFixedVariant: root.mix(root.pink, root.base, 0.5)
        readonly property color m3tertiaryFixed: root.mix(root.peach, root.text, 0.5)
        readonly property color m3tertiaryFixedDim: root.peach
        readonly property color m3onTertiaryFixed: root.crust
        readonly property color m3onTertiaryFixedVariant: root.mix(root.peach, root.base, 0.5)
    }

    Process {
        id: schemeReader

        command: ["cat", root.schemeFile]
        stdout: StdioCollector {
            onStreamFinished: {
                const txt = this.text.trim();
                if (txt === "" || txt === root.rawJson)
                    return;
                root.rawJson = txt;
                try {
                    const c = JSON.parse(txt);
                    if (c._scheme)
                        root.scheme = c._scheme;
                    root.light = c.mode === "light";
                    if (c.base)
                        root.base = c.base;
                    if (c.mantle)
                        root.mantle = c.mantle;
                    if (c.crust)
                        root.crust = c.crust;
                    if (c.text)
                        root.text = c.text;
                    if (c.subtext1)
                        root.subtext1 = c.subtext1;
                    if (c.subtext0)
                        root.subtext0 = c.subtext0;
                    if (c.surface0)
                        root.surface0 = c.surface0;
                    if (c.surface1)
                        root.surface1 = c.surface1;
                    if (c.surface2)
                        root.surface2 = c.surface2;
                    if (c.overlay0)
                        root.overlay0 = c.overlay0;
                    if (c.overlay1)
                        root.overlay1 = c.overlay1;
                    if (c.overlay2)
                        root.overlay2 = c.overlay2;
                    if (c.blue)
                        root.blue = c.blue;
                    if (c.pink)
                        root.pink = c.pink;
                    if (c.peach)
                        root.peach = c.peach;
                    if (c.red)
                        root.red = c.red;
                    if (c.green)
                        root.green = c.green;
                    if (c.yellow)
                        root.yellow = c.yellow;
                } catch (e) {
                    console.warn("Colours: failed to parse scheme:", e);
                }
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: schemeReader.running = true
    }
}
