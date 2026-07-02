pragma ComponentBehavior: Bound
import QtQuick
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

    readonly property int panelWidth: Math.min(784, Math.floor(width * 0.88))
    readonly property int searchHeight: 76
    readonly property int itemHeight: 70
    readonly property int maxResults: 8
    readonly property int panelRadius: Theme.radius
    readonly property int panelPadding: 16
    readonly property int rowRadius: Theme.radiusTight
    readonly property int openHintWidth: 96
    readonly property real panelTopMarginRatio: 0.17

    readonly property int visCount: Math.min(results.length, maxResults)
    readonly property bool showEmpty: query.length > 0 && results.length === 0
    readonly property bool showResultsBlock: visCount > 0 || showEmpty
    readonly property int resultsHeight: showResultsBlock ? panelPadding * 2 + (showEmpty ? itemHeight : visCount * itemHeight) : 0
    readonly property int panelHeight: searchHeight + (showResultsBlock ? 1 + resultsHeight : 0)

    readonly property color panelBg: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.94)
    readonly property color textPrimary: Theme.text
    readonly property color textSecondary: Theme.textSecondary
    readonly property color textPlaceholder: Theme.textMuted
    readonly property color dividerColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.1)
    readonly property color rowActive: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.22)
    readonly property color badgeBg: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.13)

    property bool open: false
    property string query: ""

    readonly property var allApps: DesktopEntries.applications.values.filter(a => a && !a.noDisplay)

    readonly property var results: {
        const q = root.query.trim().toLowerCase();
        if (q.length === 0)
            return root.allApps.slice().sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
        return root.allApps.map(a => {
            const name = (a.name || "").toLowerCase();
            const generic = (a.genericName || "").toLowerCase();
            let rank = -1;
            if (name.startsWith(q))
                rank = 0;
            else if (name.includes(q))
                rank = 1;
            else if (generic.includes(q))
                rank = 2;
            return {
                app: a,
                rank: rank
            };
        }).filter(e => e.rank >= 0).sort((x, y) => x.rank - y.rank || x.app.name.toLowerCase().localeCompare(y.app.name.toLowerCase())).map(e => e.app);
    }

    readonly property var selectedApp: results.length > 0 && list.currentIndex >= 0 ? results[list.currentIndex] : null

    function toggle() {
        root.open = !root.open;
    }

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        root.open = false;
    }

    onOpenChanged: {
        if (root.open) {
            root.query = "";
            searchInput.text = "";
            list.currentIndex = 0;
            focusTimer.start();
        }
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: searchInput.forceActiveFocus()
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            root.toggle();
        }
        function show() {
            root.open = true;
        }
        function hide() {
            root.open = false;
        }
    }

    Item {
        id: hitMask
        x: panelHost.x
        y: panelHost.y
        width: root.open ? panelHost.width : 0
        height: root.open ? panelHost.height : 0
        visible: false
    }
    mask: Region {
        item: hitMask
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    Item {
        id: panelHost

        x: (parent.width - width) / 2
        y: parent.height * root.panelTopMarginRatio
        width: root.panelWidth
        height: root.panelHeight

        transformOrigin: Item.Top
        enabled: root.open
        visible: root.open || opacity > 0.01

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.88

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: root.open ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 160
                easing.type: root.open ? Easing.OutCubic : Easing.InCubic
            }
        }

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: root.panelRadius
            color: root.panelBg
            border.width: 0
            clip: true

            readonly property bool hasResults: root.results.length > 0

            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: searchRow
                width: parent.width
                height: root.searchHeight

                FontIcon {
                    name: "search"
                    size: 26
                    iconColor: root.textSecondary
                    anchors.left: parent.left
                    anchors.leftMargin: 28
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 70
                    anchors.right: selectedAppBadge.left
                    anchors.rightMargin: 20
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true

                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    font.weight: Font.Medium
                    color: root.textPrimary
                    selectionColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.4)
                    selectedTextColor: root.textPrimary
                    focus: true

                    onTextChanged: {
                        root.query = text;
                        list.currentIndex = 0;
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.open = false;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            if (root.results.length > 0) {
                                list.currentIndex = Math.min(list.currentIndex + 1, root.results.length - 1);
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Up) {
                            if (root.results.length > 0) {
                                list.currentIndex = Math.max(list.currentIndex - 1, 0);
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.results.length > 0)
                                root.launch(root.results[list.currentIndex]);
                            event.accepted = true;
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

                Item {
                    id: selectedAppBadge
                    width: 36
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.results.length > 0
                    opacity: visible ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    Image {
                        id: selectedIcon
                        anchors.fill: parent
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        source: {
                            const app = root.selectedApp;
                            if (!app || !app.icon)
                                return "";
                            return app.icon.startsWith("/") ? "file://" + app.icon : Quickshell.iconPath(app.icon, true);
                        }
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusTight
                        color: root.badgeBg
                        visible: selectedIcon.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: root.selectedApp && root.selectedApp.name ? root.selectedApp.name.charAt(0).toUpperCase() : "?"
                            color: root.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            Rectangle {
                id: divider
                anchors.top: searchRow.bottom
                width: parent.width
                height: 1
                color: root.dividerColor
                visible: panel.hasResults || root.showEmpty
            }

            ListView {
                id: list
                anchors.top: divider.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: root.panelPadding
                anchors.rightMargin: root.panelPadding
                anchors.topMargin: root.panelPadding
                anchors.bottomMargin: root.panelPadding
                clip: true
                interactive: count > root.maxResults
                boundsBehavior: Flickable.StopAtBounds
                visible: panel.hasResults

                model: root.results
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Item {
                    id: appRow
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: root.itemHeight

                    readonly property bool active: ListView.isCurrentItem

                    Rectangle {
                        anchors.fill: parent
                        radius: root.rowRadius
                        color: root.rowActive
                        opacity: appRow.active ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }

                    Image {
                        id: appIcon
                        width: 36
                        height: 36
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        source: {
                            const ic = appRow.modelData ? appRow.modelData.icon : "";
                            if (!ic)
                                return "";
                            return ic.startsWith("/") ? "file://" + ic : Quickshell.iconPath(ic, true);
                        }
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: Theme.radiusTight
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.badgeBg
                        visible: appIcon.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: appRow.modelData && appRow.modelData.name ? appRow.modelData.name.charAt(0).toUpperCase() : "?"
                            color: root.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 72
                        anchors.right: parent.right
                        anchors.rightMargin: root.openHintWidth
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: appRow.modelData ? appRow.modelData.name : ""
                            elide: Text.ElideRight
                            color: root.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            font.weight: appRow.active ? Font.Bold : Font.Medium
                        }
                        Text {
                            width: parent.width
                            text: appRow.modelData && appRow.modelData.genericName ? appRow.modelData.genericName : ""
                            visible: text.length > 0
                            elide: Text.ElideRight
                            color: root.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 17
                            font.weight: Font.Medium
                        }
                    }

                    Row {
                        id: openHint
                        spacing: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appRow.active
                        opacity: visible ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 80
                            }
                        }

                        Text {
                            text: "Open"
                            color: root.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        FontIcon {
                            name: "return-key"
                            size: 26
                            iconColor: root.textSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = appRow.index
                        onClicked: root.launch(appRow.modelData)
                    }
                }
            }

            Item {
                anchors.top: divider.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: root.panelPadding
                anchors.bottomMargin: root.panelPadding
                anchors.bottom: parent.bottom
                visible: root.showEmpty

                Text {
                    anchors.centerIn: parent
                    text: "No results"
                    color: root.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                }
            }
        }
    }
}
