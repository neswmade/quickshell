pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    property PwObjectTracker _tracker: PwObjectTracker {
        objects: [root.sink]
    }

    function setVolume(fraction) {
        if (!sink?.audio) return
        sink.audio.muted = false
        sink.audio.volume = Math.max(0, Math.min(1, fraction))
    }

    function bumpVolume(delta) {
        setVolume(volume + delta)
    }

    function toggleMute() {
        if (!sink?.audio) return
        sink.audio.muted = !sink.audio.muted
    }
}
