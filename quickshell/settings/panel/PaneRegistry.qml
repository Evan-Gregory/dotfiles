pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property list<QtObject> panes: [
        QtObject {
            readonly property string id: "shell"
            readonly property string label: "shell"
            readonly property string icon: "tune"
            readonly property string component: "shell/ShellPane.qml"
        },
        QtObject {
            readonly property string id: "network"
            readonly property string label: "network"
            readonly property string icon: "router"
            readonly property string component: "network/NetworkingPane.qml"
        },
        QtObject {
            readonly property string id: "bluetooth"
            readonly property string label: "bluetooth"
            readonly property string icon: "settings_bluetooth"
            readonly property string component: "bluetooth/BtPane.qml"
        },
        QtObject {
            readonly property string id: "audio"
            readonly property string label: "audio"
            readonly property string icon: "volume_up"
            readonly property string component: "audio/AudioPane.qml"
        }
    ]

    readonly property int count: panes.length

    readonly property var labels: {
        const result = [];
        for (let i = 0; i < panes.length; i++) {
            result.push(panes[i].label);
        }
        return result;
    }

    function getByIndex(index: int): QtObject {
        if (index >= 0 && index < panes.length) {
            return panes[index];
        }
        return null;
    }

    function getIndexByLabel(label: string): int {
        for (let i = 0; i < panes.length; i++) {
            if (panes[i].label === label) {
                return i;
            }
        }
        return -1;
    }

    function getByLabel(label: string): QtObject {
        const index = getIndexByLabel(label);
        return getByIndex(index);
    }

    function getById(id: string): QtObject {
        for (let i = 0; i < panes.length; i++) {
            if (panes[i].id === id) {
                return panes[i];
            }
        }
        return null;
    }
}
