import QtQuick
import "./state"
import qs.settings.panel

QtObject {
    readonly property list<string> panes: PaneRegistry.labels

    required property var root
    property bool floating: false
    // Default pane: shell (scheme/uiScale/wallpaper) — the settings a user
    // opens this panel to change most often.
    property string active: "shell"
    property int activeIndex: 0
    property bool navExpanded: false

    readonly property BluetoothState bt: BluetoothState {}
    readonly property NetworkState network: NetworkState {}
    readonly property EthernetState ethernet: EthernetState {}
    readonly property VpnState vpn: VpnState {}

    onActiveChanged: activeIndex = Math.max(0, panes.indexOf(active))
    onActiveIndexChanged: if (panes[activeIndex])
        active = panes[activeIndex]

    // active/activeIndex change-handlers only fire on later mutation, not on
    // the initial property declaration above — force one sync at startup so
    // the two can never start out pointing at different panes (bit us once
    // already when PaneRegistry's pane order changed under an unsynced
    // default).
    Component.onCompleted: activeIndex = Math.max(0, panes.indexOf(active))
}
