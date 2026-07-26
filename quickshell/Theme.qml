import QtQuick
import Quickshell
import Quickshell.Io

// Semantic colour palette for the shell. Reads the active scheme from
// colors/current.json (a symlink managed by colors/set-scheme.sh) and re-reads
// on a timer, so switching schemes applies live. Baked defaults below are
// Dracula, matching colors/dracula.json, to avoid any flash before the first read.
Item {
    id: root

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
    property color sapphire: "#8be9fd"
    property color sky: "#8be9fd"
    property color teal: "#8be9fd"
    property color green: "#50fa7b"
    property color yellow: "#f1fa8c"
    property color peach: "#ffb86c"
    property color maroon: "#ff6e6e"
    property color red: "#ff5555"
    property color mauve: "#bd93f9"
    property color pink: "#ff79c6"

    property string rawJson: ""

    // Path to the active scheme, resolved relative to this file so the shell is
    // relocatable (works wherever ~/dotfiles/quickshell lives).
    readonly property string schemeFile: Qt.resolvedUrl("colors/current.json").toString().replace(/^file:\/\//, "")

    Process {
        id: schemeReader
        command: ["cat", root.schemeFile]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (txt !== "" && txt !== root.rawJson) {
                    root.rawJson = txt;
                    try {
                        let c = JSON.parse(txt);
                        if (c.base)
                            root.base = c.base;
                        if (c.mantle)
                            root.mantle = c.mantle;
                        if (c.crust)
                            root.crust = c.crust;
                        if (c.text)
                            root.text = c.text;
                        if (c.subtext0)
                            root.subtext0 = c.subtext0;
                        if (c.subtext1)
                            root.subtext1 = c.subtext1;
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
                        if (c.sapphire)
                            root.sapphire = c.sapphire;
                        if (c.sky)
                            root.sky = c.sky;
                        if (c.teal)
                            root.teal = c.teal;
                        if (c.green)
                            root.green = c.green;
                        if (c.yellow)
                            root.yellow = c.yellow;
                        if (c.peach)
                            root.peach = c.peach;
                        if (c.maroon)
                            root.maroon = c.maroon;
                        if (c.red)
                            root.red = c.red;
                        if (c.mauve)
                            root.mauve = c.mauve;
                        if (c.pink)
                            root.pink = c.pink;
                    } catch (e) {}
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
