pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import qs.utils

PanelWindow {
    id: root

    screen: Theme.shellScreen
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-power"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property int panelWidth: 320
    readonly property int buttonHeight: 52
    readonly property int panelPadding: 16
    readonly property int panelRadius: 20
    readonly property int rowRadius: 8
    readonly property int rowSpacing: 4

    readonly property var actions: [
        { label: "Logout", dispatch: "hl.dsp.exit()" },
        { label: "Suspend", command: ["systemctl", "suspend"] },
        { label: "Reboot", command: ["systemctl", "reboot"] },
        { label: "Shutdown", command: ["systemctl", "poweroff"] }
    ]

    readonly property int panelHeight: actions.length * buttonHeight
        + Math.max(0, actions.length - 1) * rowSpacing
        + panelPadding * 2

    readonly property color panelBg: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.94)
    readonly property color textPrimary: Theme.text
    readonly property color rowActive: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)

    property bool open: false

    function toggle() { root.open = !root.open }

    function runAction(action) {
        root.open = false
        if (action.dispatch !== undefined)
            Hyprland.dispatch(action.dispatch)
        else
            Quickshell.execDetached(action.command)
    }

    onOpenChanged: {
        if (root.open) {
            list.currentIndex = 0
            focusTimer.start()
        }
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: panelFocus.forceActiveFocus()
    }

    IpcHandler {
        target: "power"
        function toggle() { root.toggle() }
        function show() { root.open = true }
        function hide() { root.open = false }
    }

    Item {
        id: hitMask
        x: panelHost.x
        y: panelHost.y
        width: root.open ? panelHost.width : 0
        height: root.open ? panelHost.height : 0
        visible: false
    }
    mask: Region { item: hitMask }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    Item {
        id: panelHost
        anchors.centerIn: parent
        width: root.panelWidth
        height: root.panelHeight
        transformOrigin: Item.Center

        enabled: root.open
        visible: root.open || opacity > 0.01

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.88

        Behavior on scale { NumberAnimation { duration: 160; easing.type: root.open ? Easing.OutCubic : Easing.InCubic } }
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: root.open ? Easing.OutCubic : Easing.InCubic } }

        Rectangle {
            anchors.fill: parent
            radius: root.panelRadius
            color: root.panelBg

            FocusScope {
                id: panelFocus
                anchors.fill: parent
                focus: root.open

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) { root.open = false; event.accepted = true }
                    else if (event.key === Qt.Key_Down) {
                        if (root.actions.length > 0) {
                            list.currentIndex = Math.min(list.currentIndex + 1, root.actions.length - 1)
                            event.accepted = true
                        }
                    } else if (event.key === Qt.Key_Up) {
                        if (root.actions.length > 0) {
                            list.currentIndex = Math.max(list.currentIndex - 1, 0)
                            event.accepted = true
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const action = root.actions[list.currentIndex]
                        if (action) root.runAction(action)
                        event.accepted = true
                    }
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: root.panelPadding
                    spacing: root.rowSpacing
                    interactive: false
                    clip: true
                    model: root.actions
                    currentIndex: 0
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Item {
                        id: actionRow
                        required property int index
                        required property var modelData
                        width: ListView.view.width
                        height: root.buttonHeight

                        readonly property bool active: ListView.isCurrentItem

                        Rectangle {
                            anchors.fill: parent
                            radius: root.rowRadius
                            color: root.rowActive
                            opacity: actionRow.active ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 80 } }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: actionRow.modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.weight: actionRow.active ? Font.Bold : Font.Medium
                            color: root.textPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: list.currentIndex = actionRow.index
                            onClicked: root.runAction(actionRow.modelData)
                        }
                    }
                }
            }
        }
    }
}