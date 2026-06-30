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
    signal requestToggleMute

    readonly property bool interacting: iconHover.hovered || dragArea.pressed

    visible: opacity > 0
    opacity: root.activeState === "audio" ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    readonly property bool showVolumeBody: !root.muted
    readonly property bool showVolumeMedium: !root.muted && root.volume >= 0.33
    readonly property bool showVolumeMax: !root.muted && root.volume >= 0.66

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

            FontIcon {
                name: "volume-track"
                size: 26
                iconColor: Theme.textMuted
                anchors.centerIn: parent
            }
            FontIcon {
                name: "volume-body"
                size: 26
                iconColor: Theme.text
                anchors.centerIn: parent
                visible: root.showVolumeBody
            }
            FontIcon {
                name: "volume-medium"
                size: 26
                iconColor: Theme.text
                anchors.centerIn: parent
                visible: root.showVolumeMedium
            }
            FontIcon {
                name: "volume-max"
                size: 26
                iconColor: Theme.text
                anchors.centerIn: parent
                visible: root.showVolumeMax
            }

            HoverHandler {
                id: iconHover
            }

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
                        root.requestSetVolume(mouse.x / slider.width);
                }
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const delta = event.angleDelta.y || event.pixelDelta.y;
                if (delta > 0)
                    root.requestBumpVolume(Theme.volumeStep);
                else if (delta < 0)
                    root.requestBumpVolume(-Theme.volumeStep);
            }
        }
    }
}
