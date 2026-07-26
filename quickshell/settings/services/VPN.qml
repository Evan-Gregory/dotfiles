pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.settings.config

Singleton {
    id: root

    property bool connected: false
    // Last connect/disconnect failure, shown inline by the network pane.
    // Cleared when the connection state actually changes.
    property string lastError: ""

    readonly property bool connecting: connectProc.running || disconnectProc.running
    readonly property bool enabled: Config.vpn.provider.some(p => typeof p === "object" ? (p.enabled === true) : false)
    readonly property var providerInput: {
        const enabledProvider = Config.vpn.provider.find(p => typeof p === "object" ? (p.enabled === true) : false);
        return enabledProvider || "wireguard";
    }
    readonly property bool isCustomProvider: typeof providerInput === "object"
    readonly property string providerName: isCustomProvider ? (providerInput.name || "custom") : String(providerInput)
    readonly property string interfaceName: isCustomProvider ? (providerInput.interface || "") : ""
    readonly property var currentConfig: {
        const name = providerName;
        const iface = interfaceName;
        const defaults = getBuiltinDefaults(name, iface);

        if (isCustomProvider) {
            const custom = providerInput;
            return {
                connectCmd: custom.connectCmd || defaults.connectCmd,
                disconnectCmd: custom.disconnectCmd || defaults.disconnectCmd,
                interface: custom.interface || defaults.interface,
                displayName: custom.displayName || defaults.displayName
            };
        }

        return defaults;
    }

    function getBuiltinDefaults(name, iface) {
        const builtins = {
            "wireguard": {
                connectCmd: ["pkexec", "wg-quick", "up", iface],
                disconnectCmd: ["pkexec", "wg-quick", "down", iface],
                interface: iface,
                displayName: iface
            },
            "warp": {
                connectCmd: ["warp-cli", "connect"],
                disconnectCmd: ["warp-cli", "disconnect"],
                interface: "CloudflareWARP",
                displayName: "Warp"
            },
            "netbird": {
                connectCmd: ["netbird", "up"],
                disconnectCmd: ["netbird", "down"],
                interface: "wt0",
                displayName: "NetBird"
            },
            "tailscale": {
                connectCmd: ["tailscale", "up"],
                disconnectCmd: ["tailscale", "down"],
                interface: "tailscale0",
                displayName: "Tailscale"
            }
        };

        return builtins[name] || {
            connectCmd: [name, "up"],
            disconnectCmd: [name, "down"],
            interface: iface || name,
            displayName: name
        };
    }

    function connect(): void {
        if (!connected && !connecting && root.currentConfig && root.currentConfig.connectCmd) {
            connectProc.exec(root.currentConfig.connectCmd);
        }
    }

    function disconnect(): void {
        if (connected && !connecting && root.currentConfig && root.currentConfig.disconnectCmd) {
            disconnectProc.exec(root.currentConfig.disconnectCmd);
        }
    }

    function toggle(): void {
        if (connected) {
            disconnect();
        } else {
            connect();
        }
    }

    function checkStatus(): void {
        if (root.enabled) {
            statusProc.running = true;
        }
    }

    onConnectedChanged: lastError = ""

    Component.onCompleted: root.enabled && statusCheckTimer.start()

    Process {
        id: nmMonitor

        running: root.enabled
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: statusCheckTimer.restart()
        }
    }

    Process {
        id: statusProc

        command: ["ip", "link", "show"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const iface = root.currentConfig ? root.currentConfig.interface : "";
                root.connected = iface && text.includes(iface + ":");
            }
        }
    }

    Process {
        id: connectProc

        onExited: statusCheckTimer.start()
        stderr: StdioCollector {
            onStreamFinished: {
                const error = text.trim();
                if (error && !error.includes("[#]") && !error.includes("already exists")) {
                    console.warn("VPN connection error:", error);
                    root.lastError = error;
                } else if (error.includes("already exists")) {
                    root.connected = true;
                }
            }
        }
    }

    Process {
        id: disconnectProc

        onExited: statusCheckTimer.start()
        stderr: StdioCollector {
            onStreamFinished: {
                const error = text.trim();
                if (error && !error.includes("[#]")) {
                    console.warn("VPN disconnection error:", error);
                    root.lastError = error;
                }
            }
        }
    }

    Timer {
        id: statusCheckTimer

        interval: 500
        onTriggered: root.checkStatus()
    }
}
