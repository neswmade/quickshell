import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.utils

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

    Timer {
        id: collapseTimer
        interval: 2500
        onTriggered: root.activeState = "compact"
    }

    readonly property int expandWidthDuration: 220
    readonly property int collapseWidthDuration: 180

    NumberAnimation {
        id: widthExpandAnim
        target: root
        property: "notchWidth"
        to: Theme.notchMaxWidth
        duration: root.expandWidthDuration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: widthCollapseAnim
        target: root
        property: "notchWidth"
        to: Theme.notchMinWidth
        duration: root.collapseWidthDuration
        easing.type: Easing.OutCubic
    }

    readonly property int expandOpacityDuration: 150
    readonly property int collapseOpacityDuration: 120
    readonly property int expandOpacityDelay: 50

    Timer {
        id: contentOpacityDelay
        interval: root.expandOpacityDelay
        onTriggered: contentOpacityInAnim.restart()
    }

    NumberAnimation {
        id: contentOpacityInAnim
        target: root
        property: "contentOpacity"
        to: 1
        duration: root.expandOpacityDuration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: contentOpacityOutAnim
        target: root
        property: "contentOpacity"
        to: 0
        duration: root.collapseOpacityDuration
        easing.type: Easing.OutCubic
    }

    onActiveStateChanged: {
        const expanding = activeState !== "compact"
        if (expanding) {
            widthCollapseAnim.stop()
            contentOpacityOutAnim.stop()
            contentOpacityDelay.stop()
            widthExpandAnim.restart()
            contentOpacityDelay.restart()
        } else {
            widthExpandAnim.stop()
            contentOpacityInAnim.stop()
            contentOpacityDelay.stop()
            contentOpacityOutAnim.restart()
            widthCollapseAnim.restart()
        }
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
    mask: Region { item: hitMask }

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
            startX: 0; startY: 0
            PathLine { x: 0; y: Theme.borderThickness }
            PathArc {
                x: Theme.notchRadius; y: Theme.borderThickness + Theme.notchRadius
                radiusX: Theme.notchRadius; radiusY: Theme.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: Theme.notchRadius; y: Theme.notchHeight - Theme.notchRadius }
            PathArc {
                x: Theme.notchRadius * 2; y: Theme.notchHeight
                radiusX: Theme.notchRadius; radiusY: Theme.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine { x: shape.width - Theme.notchRadius * 2; y: Theme.notchHeight }
            PathArc {
                x: shape.width - Theme.notchRadius; y: Theme.notchHeight - Theme.notchRadius
                radiusX: Theme.notchRadius; radiusY: Theme.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine { x: shape.width - Theme.notchRadius; y: Theme.borderThickness + Theme.notchRadius }
            PathArc {
                x: shape.width; y: Theme.borderThickness
                radiusX: Theme.notchRadius; radiusY: Theme.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
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

        // TODO: WorkspaceRuler  (visible: root.activeState === "compact")
        // TODO: AudioHud        (visible: root.activeState === "audio")
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered)
                collapseTimer.stop()
            else if (root.activeState !== "compact")
                collapseTimer.restart()
        }
    }
}
