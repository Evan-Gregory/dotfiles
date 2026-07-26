import QtQuick
import Quickshell
import Quickshell.Io
import "WindowRegistry.js" as LayoutMath

Item {
    id: root
    visible: false

    property real currentWidth: 1920.0
    property real currentHeight: 1080.0
    property real uiScale: 1.0

    property real baseScale: LayoutMath.getScale(currentWidth, currentHeight, uiScale)

    function s(val) {
        return LayoutMath.s(val, baseScale);
    }

    // Optional per-user scale override, resolved relative to this file so the
    // shell is self-contained. Absent file -> uiScale stays 1.0 (see settings.json).
    readonly property string settingsFile: Qt.resolvedUrl("settings.json").toString().replace(/^file:\/\//, "")

    Process {
        id: scaleReader
        command: ["bash", "-c", "cat '" + root.settingsFile + "' 2>/dev/null || echo '{}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (this.text && this.text.trim().length > 0 && this.text.trim() !== "{}") {
                        let parsed = JSON.parse(this.text);
                        if (parsed.uiScale !== undefined && root.uiScale !== parsed.uiScale) {
                            root.uiScale = parsed.uiScale;
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: scaleWatcher
        command: ["bash", "-c", "F='" + root.settingsFile + "'; while [ ! -f \"$F\" ]; do sleep 1; done; inotifywait -qq -e modify,close_write \"$F\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                scaleReader.running = false;
                scaleReader.running = true;
                scaleWatcher.running = false;
                scaleWatcher.running = true;
            }
        }
    }
}
