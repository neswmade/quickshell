pragma ComponentBehavior: Bound
import QtQuick
import qs.utils
import qs.services

Item {
    id: root

    property string activeState: "compact"
    required property var screen

    readonly property int stepPx: 46

    readonly property int rulerMax: Math.max(Workspaces.activeWs, Workspaces.maxOccupied) + 2

    visible: opacity > 0
    opacity: root.activeState === "workspace" ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: strip
        height: parent.height
        x: root.width / 2 - root.stepPx / 2 - (Workspaces.activeWs - 1) * root.stepPx

        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: root.rulerMax
            delegate: Item {
                id: tick
                required property int index
                readonly property int wsNumber: index + 1
                readonly property bool isActive: wsNumber === Workspaces.activeWs
                readonly property bool isOccupied: Workspaces.occupied[wsNumber] === true

                width: root.stepPx
                height: root.height

                Repeater {
                    model: [-3, -2, -1, 1, 2, 3]
                    delegate: Rectangle {
                        required property int modelData
                        visible: !(tick.wsNumber === 1 && modelData < 0)
                        width: 1
                        height: 6
                        radius: 0.5
                        color: Workspaces.inSpecialWs(root.screen) ? Theme.text : Theme.textMuted
                        opacity: 0.3
                        x: tick.width / 2 + modelData * (root.stepPx / 6) - width / 2
                        anchors.verticalCenter: tick.verticalCenter
                    }
                }

                Rectangle {
                    width: 2
                    height: 14
                    radius: 1
                    anchors.horizontalCenter: tick.horizontalCenter
                    anchors.verticalCenter: tick.verticalCenter
                    color: Workspaces.inSpecialWs(root.screen) ? Theme.textMuted : tick.isActive ? Theme.text : tick.isOccupied ? Theme.textSecondary : Theme.textMuted
                    opacity: tick.isActive || tick.isOccupied ? 1 : 0.5

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                }
            }
        }
    }

    Text {
        text: Workspaces.inSpecialWs(root.screen) ? "S" : Workspaces.activeWs
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 22
        font.weight: Font.Bold
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
    }
}
