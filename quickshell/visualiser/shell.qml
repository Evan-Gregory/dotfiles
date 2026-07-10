import Quickshell
import Quickshell.Wayland
import QtQuick
import Cava

ShellRoot {
    id: root

    // One shared cava provider + capture for every screen. The ServiceRef is
    // what activates the provider (ref-counted); keeping it alive for the whole
    // app means capture runs whenever the visualiser is running.
    CavaProvider {
        id: cavaSource
        bars: 50
    }
    ServiceRef {
        service: cavaSource
    }

    // One background-layer surface per monitor.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property ShellScreen modelData
            screen: modelData

            WlrLayershell.namespace: "visualiser"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            color: "transparent"
            surfaceFormat.opaque: false

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Visualiser {
                anchors.fill: parent
                cava: cavaSource
            }
        }
    }
}
