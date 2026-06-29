pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.utils
import "../../components"

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
    WlrLayershell.namespace: "nesw-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property int panelWidth: Math.min(640, Math.floor(width * 0.88))
    readonly property int searchHeight: 64
    readonly property int itemHeight: 56
    readonly property int maxResults: 8
    readonly property int panelRadius: 20
    readonly property int panelPadding: 12
    readonly property int rowRadius: 10
    readonly property real topMarginRatio: 0.2

    readonly property color panelBg: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.94)
    readonly property color textPrimary: Theme.text
    readonly property color textSecondary: Theme.textSecondary
    readonly property color textPlaceholder: Theme.textMuted
    readonly property color divider: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.1)
    readonly property color rowActive: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)

    property bool open: false
    property string query: ""

    readonly property var allApps: DesktopEntries.applications.values
        .filter(a => a && !a.noDisplay)

    readonly property var results: {
        const q = root.query.trim().toLowerCase()
        if (q.length === 0)
            return root.allApps.slice().sort((a, b) =>
                a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
        return root.allApps
            .filter(a => a.name.toLowerCase().includes(q))
            .sort((a, b) => {
                const an = a.name.toLowerCase()
                const bn = b.name.toLowerCase()
                const as = an.startsWith(q) ? 0 : 1
                const bs = bn.startsWith(q) ? 0 : 1
                if (as !== bs) return as - bs
                return an.localeCompare(bn)
            })
    }

    function toggle() { root.open = !root.open }

    function launch(app) {
        if (!app) return
        app.execute()
        root.open = false
    }

    onOpenChanged: {
        if (root.open) {
            root.query = ""
            searchInput.text = ""
            list.currentIndex = 0
            focusTimer.start()
        }
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: searchInput.forceActiveFocus()
    }

    IpcHandler {
        target: "launcher"
        function toggle() { root.toggle() }
        function show() { root.open = true }
        function hide() { root.open = false }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    Item {
        id: panelHost
        x: (parent.width - width) / 2
        y: parent.height * root.topMarginRatio
        width: root.panelWidth
        height: searchRow.height + (root.results.length > 0 ? 1 + list.height : 0)
        transformOrigin: Item.Top
        visible: root.open
        scale: root.open ? 1 : 0.92
        opacity: root.open ? 1 : 0

        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: root.panelRadius
            color: root.panelBg
            clip: true

            Item {
                id: searchRow
                width: parent.width
                height: root.searchHeight

                FontIcon {
                    name: "search"
                    size: 22
                    iconColor: root.textSecondary
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 60
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    color: root.textPrimary
                    selectionColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)

                    onTextChanged: {
                        root.query = text
                        list.currentIndex = 0
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) { root.open = false; event.accepted = true }
                        else if (event.key === Qt.Key_Down) {
                            if (root.results.length > 0) {
                                list.currentIndex = Math.min(list.currentIndex + 1, root.results.length - 1)
                                event.accepted = true
                            }
                        } else if (event.key === Qt.Key_Up) {
                            if (root.results.length > 0) {
                                list.currentIndex = Math.max(list.currentIndex - 1, 0)
                                event.accepted = true
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.results.length > 0) root.launch(root.results[list.currentIndex])
                            event.accepted = true
                        }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search apps…"
                        color: root.textPlaceholder
                        font: searchInput.font
                        visible: searchInput.text.length === 0
                    }
                }
            }

            Rectangle {
                anchors.top: searchRow.bottom
                width: parent.width
                height: 1
                color: root.divider
                visible: root.results.length > 0
            }

            ListView {
                id: list
                anchors.top: searchRow.bottom
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: root.panelPadding
                clip: true
                interactive: count > root.maxResults
                boundsBehavior: Flickable.StopAtBounds
                visible: root.results.length > 0
                implicitHeight: Math.min(root.results.length, root.maxResults) * root.itemHeight

                model: root.results
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Item {
                    id: row
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: root.itemHeight

                    readonly property bool active: ListView.isCurrentItem

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: root.rowRadius
                        color: root.rowActive
                        opacity: row.active ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 60 } }
                    }

                    Image {
                        id: appIcon
                        width: 32
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize.width: 32
                        sourceSize.height: 32
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        source: {
                            const ic = row.modelData ? row.modelData.icon : ""
                            if (!ic) return ""
                            return ic.startsWith("/") ? "file://" + ic : Quickshell.iconPath(ic, "image-missing")
                        }
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.left: appIcon.right
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        text: row.modelData ? row.modelData.name : ""
                        elide: Text.ElideRight
                        color: root.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        font.weight: row.active ? Font.DemiBold : Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: root.launch(row.modelData)
                    }
                }
            }

            Text {
                anchors.top: searchRow.bottom
                anchors.topMargin: root.panelPadding * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No results"
                color: root.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 18
                visible: root.open && root.results.length === 0 && root.query.length > 0
            }
        }
    }
}
