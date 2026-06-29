import QtQuick
import qs.utils

Item {
    id: root

    property real value: 0
    property bool muted: false

    implicitHeight: Theme.sliderHeight
    implicitWidth: 200

    Rectangle {
        anchors.fill: parent
        radius: Theme.sliderRadius
        color: Theme.sliderTrack
        opacity: Theme.sliderTrackOpacity
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height
        radius: Theme.sliderRadius
        width: parent.width * Math.max(0, Math.min(1, root.value))
        color: root.muted ? Theme.sliderMuted : Theme.sliderFill

        Behavior on width {
            NumberAnimation {
                duration: Theme.sliderFillAnim
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: Theme.sliderColorAnim
            }
        }
    }
}
