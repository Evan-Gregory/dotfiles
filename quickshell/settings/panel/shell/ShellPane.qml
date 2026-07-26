pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.settings.components
import qs.settings.components.controls
import qs.settings.components.containers
import qs.settings.services
import qs.settings.config
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// This shell's own configuration surface: colour scheme, UI scale, and the
// wallpaper picker's source directory. Unlike the other panes (which mirror
// real system state via nmcli/bluez/pipewire), this one drives the shell's
// own plain-file config (colors/*.json + settings.json).
Item {
    id: root

    required property Session session

    anchors.fill: parent

    // ── scheme discovery ────────────────────────────────────────────────
    readonly property string colorsDir: Qt.resolvedUrl("../../../colors").toString().replace(/^file:\/\//, "")
    property var schemes: []

    function refreshSchemes(): void {
        schemeScanner.running = true;
    }

    Process {
        id: schemeScanner

        // One combined listing avoids per-file process spawn; each entry is
        // delimited by a marker line carrying the scheme's name (current.json
        // is the active-scheme symlink, not a scheme of its own — skipped).
        command: ["bash", "-c", `for f in "${root.colorsDir}"/*.json; do name=$(basename "$f" .json); [ "$name" = "current" ] && continue; printf '@@SCHEME:%s@@\\n' "$name"; cat "$f"; echo; done`]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.split(/@@SCHEME:([^@]+)@@\n/).slice(1);
                const parsed = [];
                for (let i = 0; i + 1 < parts.length; i += 2) {
                    const name = parts[i];
                    try {
                        const data = JSON.parse(parts[i + 1]);
                        parsed.push({
                            name: name,
                            base: data.base ?? "#000000",
                            mantle: data.mantle ?? data.base ?? "#000000",
                            blue: data.blue ?? data.mauve ?? "#888888",
                            pink: data.pink ?? data.red ?? "#888888",
                            mode: data.mode ?? "dark"
                        });
                    } catch (e) {
                        console.warn("ShellPane: failed to parse scheme", name, e);
                    }
                }
                parsed.sort((a, b) => a.name.localeCompare(b.name));
                root.schemes = parsed;
            }
        }
    }

    Process {
        id: schemeSetter

        function setScheme(name: string): void {
            command = ["bash", "-c", `"${root.colorsDir}/set-scheme.sh" "${name}"`];
            running = true;
        }
    }

    // ── wallpaper dir validation ─────────────────────────────────────────
    property bool wallpaperDirValid: true

    Process {
        id: dirChecker

        function check(path: string): void {
            command = ["bash", "-c", `[ -d "${path}" ] && echo yes || echo no`];
            running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: root.wallpaperDirValid = this.text.trim() === "yes"
        }
    }

    function checkWallpaperDir(): void {
        const dir = Config.wallpaperDir || (Quickshell.env("WALLPAPER_DIR") || (Quickshell.env("HOME") + "/dotfiles/hypr/wallpapers"));
        dirChecker.check(dir);
    }

    Component.onCompleted: {
        root.refreshSchemes();
        root.checkWallpaperDir();
    }

    StyledFlickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content.implicitHeight

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: parent
        }

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: qsTr("Shell")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            CollapsibleSection {
                id: schemeSection

                Layout.fillWidth: true
                title: qsTr("Colour scheme")
                description: qsTr("Applies live across the whole shell")
                showBackground: true
                expanded: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small / 2

                    Repeater {
                        model: root.schemes

                        delegate: StyledRect {
                            id: schemeDelegate

                            required property var modelData

                            readonly property bool isCurrent: modelData.name === Colours.scheme

                            Layout.fillWidth: true
                            implicitHeight: schemeRow.implicitHeight + Appearance.padding.normal * 2

                            radius: Appearance.rounding.normal
                            color: isCurrent ? Colours.tPalette.m3surfaceContainer : "transparent"
                            border.width: isCurrent ? 1 : 0
                            border.color: Colours.palette.m3primary

                            StateLayer {
                                function onClicked(): void {
                                    schemeSetter.setScheme(schemeDelegate.modelData.name);
                                }
                            }

                            RowLayout {
                                id: schemeRow

                                anchors.fill: parent
                                anchors.margins: Appearance.padding.normal
                                spacing: Appearance.spacing.normal

                                StyledRect {
                                    id: preview

                                    implicitWidth: previewIcon.implicitWidth
                                    implicitHeight: previewIcon.implicitWidth

                                    radius: Appearance.rounding.full
                                    color: schemeDelegate.modelData.base

                                    MaterialIcon {
                                        id: previewIcon
                                        visible: false
                                        text: "circle"
                                        font.pointSize: Appearance.font.size.large
                                    }

                                    Item {
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        implicitWidth: parent.implicitWidth / 2
                                        clip: true

                                        StyledRect {
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            anchors.right: parent.right
                                            implicitWidth: preview.implicitWidth
                                            radius: preview.radius
                                            color: schemeDelegate.modelData.blue
                                        }
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: schemeDelegate.modelData.name
                                    font.capitalization: Font.Capitalize
                                }

                                Loader {
                                    active: schemeDelegate.isCurrent
                                    sourceComponent: MaterialIcon {
                                        text: "check"
                                        color: Colours.palette.m3primary
                                    }
                                }
                            }
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: root.schemes.length === 0
                        text: qsTr("No schemes found in colors/")
                        color: Colours.palette.m3outline
                    }
                }
            }

            CollapsibleSection {
                id: scaleSection

                Layout.fillWidth: true
                title: qsTr("UI scale")
                description: qsTr("Applies to this settings panel and other components that read settings.json")
                showBackground: true
                expanded: true

                SectionContainer {
                    contentSpacing: Appearance.spacing.normal

                    SliderInput {
                        Layout.fillWidth: true

                        label: qsTr("Scale")
                        value: Config.uiScale
                        from: 0.5
                        to: 2.0
                        decimals: 2
                        suffix: "×"
                        validator: DoubleValidator {
                            bottom: 0.5
                            top: 2.0
                        }

                        onValueModified: newValue => {
                            Config.uiScale = newValue;
                            Config.save();
                        }
                    }
                }
            }

            CollapsibleSection {
                id: wallpaperSection

                Layout.fillWidth: true
                title: qsTr("Wallpaper directory")
                description: qsTr("Source folder for the wallpaper picker (SUPER+W)")
                showBackground: true
                expanded: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.normal

                        StyledTextField {
                            id: wallpaperDirField

                            Layout.fillWidth: true
                            text: Config.wallpaperDir
                            placeholderText: (Quickshell.env("WALLPAPER_DIR") || (Quickshell.env("HOME") + "/dotfiles/hypr/wallpapers")) + qsTr("  (default)")

                            onAccepted: {
                                Config.wallpaperDir = text;
                                Config.save();
                                root.checkWallpaperDir();
                            }
                        }

                        IconButton {
                            icon: "refresh"
                            type: IconButton.Text
                            onClicked: root.checkWallpaperDir()
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: !root.wallpaperDirValid
                        text: qsTr("Directory does not exist")
                        color: Colours.palette.m3error
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Leave empty to use $WALLPAPER_DIR or the built-in default")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }
        }
    }
}
