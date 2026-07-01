pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.utils
import qs.services

PanelWindow {
    id: root

    screen: Theme.shellScreen
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: Theme.notchHeight - Theme.borderThickness
    WlrLayershell.namespace: "nesw-notch"

    property string activeState: "compact"
    property real notchWidth: Theme.notchMinWidth
    property real contentOpacity: 0
    property real _lastVolume: -1

    Connections {
        target: Audio
        function onVolumeChanged() {
            if (root._lastVolume < 0) {
                root._lastVolume = Audio.volume;
                return;
            }
            if (Math.abs(Audio.volume - root._lastVolume) > 0.001) {
                root._lastVolume = Audio.volume;
                root.showAudio();
            }
        }
        function onMutedChanged() {
            root.showAudio();
        }
    }

    function showAudio() {
        collapseTimer.stop();
        activeState = "audio";
        audioTimer.restart();
    }

    Connections {
        target: Workspaces
        function onActiveWsChanged() {
            root.showWorkspace();
        }
        function onInSpecialWsChanged() {
            root.showWorkspace();
        }
    }

    function showWorkspace() {
        audioTimer.stop();
        activeState = "workspace";
        collapseTimer.restart();
    }

    Timer {
        id: collapseTimer
        interval: 2500
        onTriggered: root.activeState = "compact"
    }

    Timer {
        id: audioTimer
        interval: 2000
        onTriggered: {
            if (audioHud.interacting) {
                restart();
                return;
            }
            root.activeState = "compact";
        }
    }

    readonly property int expandWidthDuration: 220
    readonly property int collapseWidthDuration: 180
    readonly property int expandOpacityDuration: 150
    readonly property int collapseOpacityDuration: 120

    Behavior on notchWidth {
        NumberAnimation {
            duration: root.activeState === "compact" ? root.collapseWidthDuration : root.expandWidthDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on contentOpacity {
        NumberAnimation {
            duration: root.activeState === "compact" ? root.collapseOpacityDuration : root.expandOpacityDuration
            easing.type: Easing.OutCubic
        }
    }

    onActiveStateChanged: {
        const expanding = activeState !== "compact";
        root.notchWidth = expanding ? Theme.notchMaxWidth : Theme.notchMinWidth;
        root.contentOpacity = expanding ? 1 : 0;
    }

    Item {
        id: hitMask
        anchors.fill: parent
        visible: false
        Item {
            x: (parent.width - shape.width) / 2
            y: 0
            width: shape.width
            height: Theme.notchHeight
        }
    }
    mask: Region {
        item: hitMask
    }

    Shape {
        id: shape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth + Theme.notchRadius * 2
        height: Theme.notchHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.bg
            strokeWidth: 0
            startX: 0
            startY: 0
            PathLine {
                x: 0
                y: Theme.borderThickness
            }
            PathArc {
                x: Theme.notchRadius
                y: Theme.borderThickness + Theme.notchRadius
                radiusX: Theme.notchRadius
                radiusY: Theme.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: Theme.notchRadius
                y: Theme.notchHeight - Theme.notchRadius
            }
            PathArc {
                x: Theme.notchRadius * 2
                y: Theme.notchHeight
                radiusX: Theme.notchRadius
                radiusY: Theme.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: shape.width - Theme.notchRadius * 2
                y: Theme.notchHeight
            }
            PathArc {
                x: shape.width - Theme.notchRadius
                y: Theme.notchHeight - Theme.notchRadius
                radiusX: Theme.notchRadius
                radiusY: Theme.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: shape.width - Theme.notchRadius
                y: Theme.borderThickness + Theme.notchRadius
            }
            PathArc {
                x: shape.width
                y: Theme.borderThickness
                radiusX: Theme.notchRadius
                radiusY: Theme.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: shape.width
                y: 0
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.borderThickness
        width: root.notchWidth - Theme.notchPadding * 2
        height: Theme.notchHeight - Theme.borderThickness
        clip: true
        opacity: root.contentOpacity

        AudioHud {
            id: audioHud
            anchors.fill: parent
            activeState: root.activeState
            volume: Audio.volume
            muted: Audio.muted
            onRequestSetVolume: fraction => Audio.setVolume(fraction)
            onRequestBumpVolume: delta => Audio.bumpVolume(delta)
            onRequestToggleMute: Audio.toggleMute()
        }

        WorkspaceHud {
            screen: root.screen
            anchors.fill: parent
            activeState: root.activeState
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered)
                collapseTimer.stop();
            else if (root.activeState !== "compact")
                collapseTimer.restart();
        }
    }
}
