pragma Singleton

import qs.settings.config
import Quickshell
import Quickshell.Io
import QtQuick

// Audio service backed by pactl (PulseAudio protocol, served by PipeWire).
// State is fetched as JSON via `pactl -f json list ...` and kept fresh by a
// persistent `pactl subscribe` event stream, mirroring how the network
// service sits on nmcli.
//
// Nodes (sinks/sources/application streams) are stable QtObject wrappers,
// updated in place so QML bindings and open delegates survive refreshes.
// All mutations go through the set* functions below — they apply
// optimistically to the local wrapper (keeps sliders smooth) and then run
// pactl; the subscribe stream confirms with a refresh.
Singleton {
    id: root

    property list<QtObject> sinks: []
    property list<QtObject> sources: []
    property list<QtObject> streams: []

    property QtObject sink: null
    property QtObject source: null

    readonly property bool muted: !!sink?.audio.muted
    readonly property real volume: sink?.audio.volume ?? 0
    readonly property bool sourceMuted: !!source?.audio.muted
    readonly property real sourceVolume: source?.audio.volume ?? 0

    function setVolume(newVolume: real): void {
        if (sink) {
            const v = Math.max(0, Math.min(Config.audio.maxVolume, newVolume));
            sink.audio.muted = false;
            sink.audio.volume = v;
            ctl.exec(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "0"]);
            ctl.exec(["pactl", "set-sink-volume", "@DEFAULT_SINK@", `${Math.round(v * 100)}%`]);
        }
    }

    function incrementVolume(amount: real): void {
        setVolume(volume + (amount || Config.audio.increment));
    }

    function decrementVolume(amount: real): void {
        setVolume(volume - (amount || Config.audio.increment));
    }

    function setMuted(newMuted: bool): void {
        if (sink) {
            sink.audio.muted = newMuted;
            ctl.exec(["pactl", "set-sink-mute", "@DEFAULT_SINK@", newMuted ? "1" : "0"]);
        }
    }

    function setSourceVolume(newVolume: real): void {
        if (source) {
            const v = Math.max(0, Math.min(Config.audio.maxVolume, newVolume));
            source.audio.muted = false;
            source.audio.volume = v;
            ctl.exec(["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "0"]);
            ctl.exec(["pactl", "set-source-volume", "@DEFAULT_SOURCE@", `${Math.round(v * 100)}%`]);
        }
    }

    function incrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume + (amount || Config.audio.increment));
    }

    function decrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume - (amount || Config.audio.increment));
    }

    function setSourceMuted(newMuted: bool): void {
        if (source) {
            source.audio.muted = newMuted;
            ctl.exec(["pactl", "set-source-mute", "@DEFAULT_SOURCE@", newMuted ? "1" : "0"]);
        }
    }

    function setAudioSink(newSink: var): void {
        if (newSink?.name)
            ctl.exec(["pactl", "set-default-sink", newSink.name]);
    }

    function setAudioSource(newSource: var): void {
        if (newSource?.name)
            ctl.exec(["pactl", "set-default-source", newSource.name]);
    }

    function setStreamVolume(stream: var, newVolume: real): void {
        if (stream) {
            const v = Math.max(0, Math.min(Config.audio.maxVolume, newVolume));
            stream.audio.muted = false;
            stream.audio.volume = v;
            ctl.exec(["pactl", "set-sink-input-mute", String(stream.nodeId), "0"]);
            ctl.exec(["pactl", "set-sink-input-volume", String(stream.nodeId), `${Math.round(v * 100)}%`]);
        }
    }

    function setStreamMuted(stream: var, newMuted: bool): void {
        if (stream) {
            stream.audio.muted = newMuted;
            ctl.exec(["pactl", "set-sink-input-mute", String(stream.nodeId), newMuted ? "1" : "0"]);
        }
    }

    function getStreamVolume(stream: var): real {
        return stream?.audio.volume ?? 0;
    }

    function getStreamMuted(stream: var): bool {
        return !!stream?.audio.muted;
    }

    function getStreamName(stream: var): string {
        if (!stream)
            return qsTr("Unknown");
        return stream.applicationName || stream.description || stream.name || qsTr("Unknown Application");
    }

    // ── internals ────────────────────────────────────────────────────────

    component Node: QtObject {
        property int nodeId
        property string name
        property string description
        property string applicationName
        readonly property bool ready: true
        readonly property QtObject audio: QtObject {
            property real volume: 0
            property bool muted: false
        }
    }

    Component {
        id: nodeFactory

        Node {}
    }

    function maxChannelVolume(volumeObj: var): real {
        let max = 0;
        for (const ch in volumeObj) {
            const pct = parseInt(volumeObj[ch].value_percent);
            if (!isNaN(pct))
                max = Math.max(max, pct / 100);
        }
        return max;
    }

    // Update `current` wrapper list in place from parsed pactl entries.
    // Returns a new array only when membership changed, else null.
    function syncNodes(current: var, entries: var): var {
        const byId = {};
        for (const node of current)
            byId[node.nodeId] = node;

        let membershipChanged = entries.length !== current.length;
        const next = [];
        for (const e of entries) {
            let node = byId[e.index];
            if (!node) {
                membershipChanged = true;
                node = nodeFactory.createObject(root, {
                    nodeId: e.index
                });
            } else {
                delete byId[e.index];
            }
            node.name = e.name ?? "";
            node.description = e.description ?? "";
            node.applicationName = e.applicationName ?? "";
            node.audio.volume = e.volume;
            node.audio.muted = e.muted;
            next.push(node);
        }
        for (const stale in byId)
            byId[stale].destroy();
        return membershipChanged ? next : null;
    }

    // pactl's JSON output for `list ...` does not end in a newline, so a
    // plain `echo` marker between commands can land glued to the previous
    // command's closing bracket with no separator at all. Distinctive
    // inline markers (split by substring, not by surrounding whitespace)
    // sidestep that entirely.
    readonly property string markSinks: "@@Q_SINKS_END@@"
    readonly property string markSources: "@@Q_SOURCES_END@@"
    readonly property string markInputs: "@@Q_INPUTS_END@@"
    readonly property string markDefSink: "@@Q_DEFSINK_END@@"

    function applyState(text: string): void {
        const i1 = text.indexOf(markSinks);
        const i2 = text.indexOf(markSources, i1);
        const i3 = text.indexOf(markInputs, i2);
        const i4 = text.indexOf(markDefSink, i3);
        if (i1 < 0 || i2 < 0 || i3 < 0 || i4 < 0)
            return;

        try {
            const rawSinks = JSON.parse(text.slice(0, i1) || "[]");
            const rawSources = JSON.parse(text.slice(i1 + markSinks.length, i2) || "[]");
            const rawInputs = JSON.parse(text.slice(i2 + markSources.length, i3) || "[]");
            const defaultSink = text.slice(i3 + markInputs.length, i4).trim();
            const defaultSource = text.slice(i4 + markDefSink.length).trim();

            // Some backends (e.g. AirPlay/raop sinks with no advertised
            // name) report the literal string "(null)" as their
            // description rather than leaving it empty or absent.
            const cleanDescription = d => (!d || d === "(null)") ? "" : d;

            const sinkEntries = rawSinks.map(s => ({
                index: s.index,
                name: s.name,
                description: cleanDescription(s.description),
                applicationName: "",
                volume: maxChannelVolume(s.volume),
                muted: !!s.mute
            }));
            const sourceEntries = rawSources.filter(s => !s.name.endsWith(".monitor")).map(s => ({
                index: s.index,
                name: s.name,
                description: cleanDescription(s.description),
                applicationName: "",
                volume: maxChannelVolume(s.volume),
                muted: !!s.mute
            }));
            const streamEntries = rawInputs.map(s => ({
                index: s.index,
                name: s.properties?.["application.process.binary"] ?? "",
                description: s.properties?.["media.name"] ?? "",
                applicationName: s.properties?.["application.name"] ?? "",
                volume: maxChannelVolume(s.volume),
                muted: !!s.mute
            }));

            const newSinks = syncNodes(sinks, sinkEntries);
            if (newSinks)
                sinks = newSinks;
            const newSources = syncNodes(sources, sourceEntries);
            if (newSources)
                sources = newSources;
            const newStreams = syncNodes(streams, streamEntries);
            if (newStreams)
                streams = newStreams;

            sink = sinks.find(s => s.name === defaultSink) ?? null;
            source = sources.find(s => s.name === defaultSource) ?? null;
        } catch (e) {
            console.warn("Audio: failed to parse pactl state:", e);
        }
    }

    Process {
        id: ctl

        function exec(cmd: var): void {
            // Quickshell Process.exec replaces any running command; volume
            // spam during slider drags is fine since the final value wins
            // and the subscribe stream reconciles.
            command = cmd;
            running = true;
        }
    }

    Process {
        id: stateReader

        command: ["bash", "-c", `pactl -f json list sinks; printf '${root.markSinks}'; pactl -f json list sources; printf '${root.markSources}'; pactl -f json list sink-inputs; printf '${root.markInputs}'; pactl get-default-sink; printf '${root.markDefSink}'; pactl get-default-source`]
        stdout: StdioCollector {
            onStreamFinished: root.applyState(this.text)
        }
    }

    Process {
        id: subscriber

        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("sink") || line.includes("source") || line.includes("server"))
                    refreshDebounce.restart();
            }
        }
        // pactl subscribe dying (e.g. pipewire-pulse restart) would silently
        // freeze the pane; restart it and re-sync.
        onExited: {
            refreshDebounce.restart();
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer

        interval: 2000
        onTriggered: subscriber.running = true
    }

    Timer {
        id: refreshDebounce

        interval: 120
        onTriggered: stateReader.running = true
    }

    Component.onCompleted: stateReader.running = true
}
