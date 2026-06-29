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

    implicitHeight: barHeight + cornerRadius
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-topbar"

    readonly property int barHeight: 40
    readonly property int borderWidth: Theme.borderThickness
    readonly property int cornerRadius: Theme.rounding
    readonly property color barColor: "#990a0a0a"

    mask: Region {}

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.barColor
            strokeWidth: 0

            startX: 0
            startY: 0

            PathLine { x: shape.width; y: 0 }

            PathLine {
                x: shape.width
                y: root.barHeight + root.cornerRadius
            }

            PathLine {
                x: shape.width - root.borderWidth
                y: root.barHeight + root.cornerRadius
            }

            PathArc {
                x: shape.width - root.borderWidth - root.cornerRadius
                y: root.barHeight
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.borderWidth + root.cornerRadius
                y: root.barHeight
            }

            PathArc {
                x: root.borderWidth
                y: root.barHeight + root.cornerRadius
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: 0
                y: root.barHeight + root.cornerRadius
            }

            PathLine { x: 0; y: 0 }
        }
    }
}
