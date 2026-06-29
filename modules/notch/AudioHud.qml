pragma ComponentBehavior: Bound
import QtQuick
import qs.utils
import "../../components"

Item {
    id: root

    property string activeState: "compact"
    property real volume: 0
    property bool muted: false

    signal requestSetVolume(real fraction)
    signal requestBumpVolume(real delta)
    signal requestToggleMute()

    readonly property bool interacting: iconHover.hovered || dragArea.pressed

    visible: opacity > 0
    opacity: root.activeState === "audio" ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    readonly property url currentIcon: {
        if (root.muted)
            return Qt.resolvedUrl("../icons/assets/volume-muted.svg")
        if (root.volume <= 0.001)
            return Qt.resolvedUrl("../icons/assets/volume-none.svg")
        if (root.volume < 0.33)
            return Qt.resolvedUrl("../icons/assets/volume-low.svg")
        if (root.volume < 0.66)
            return Qt.resolvedUrl("../icons/assets/volume-medium.svg")
        return Qt.resolvedUrl("../icons/assets/volume-max.svg")
    }

    Item {
        id: layout
        anchors.centerIn: parent
        width: parent.width
        height: Math.max(iconHit.height, slider.implicitHeight)

        Item {
            id: iconHit
            anchors.left: layout.left
            anchors.verticalCenter: layout.verticalCenter
            width: 26
            height: 26

            Image {
                anchors.centerIn: parent
                source: root.currentIcon
                width: 26
                height: 26
                sourceSize: Qt.size(26, 26)
                fillMode: Image.PreserveAspectFit
            }

            HoverHandler { id: iconHover }

            TapHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
                onTapped: root.requestToggleMute()
            }
        }

        StyledSlider {
            id: slider
            anchors.left: iconHit.right
            anchors.leftMargin: 10
            anchors.right: layout.right
            anchors.verticalCenter: layout.verticalCenter
            value: root.volume
            muted: root.muted
        }

        Item {
            anchors.fill: slider
            anchors.topMargin: -12
            anchors.bottomMargin: -12
            anchors.leftMargin: -6
            anchors.rightMargin: -6

            MouseArea {
                id: dragArea
                anchors.fill: parent
                preventStealing: true
                onPressed: mouse => root.requestSetVolume(mouse.x / slider.width)
                onPositionChanged: mouse => {
                    if (dragArea.pressed)
                        root.requestSetVolume(mouse.x / slider.width)
                }
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const delta = event.angleDelta.y || event.pixelDelta.y
                if (delta > 0)
                    root.requestBumpVolume(Theme.volumeStep)
                else if (delta < 0)
                    root.requestBumpVolume(-Theme.volumeStep)
            }
        }
    }
}
