pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.utils
import qs.services
import "../../components"

Row {
    id: root

    spacing: Theme.statusIconSize

    Item {
        width: Theme.statusIconSize
        height: Theme.statusIconSize
        anchors.verticalCenter: parent.verticalCenter

        FontIcon {
            name: "bluetooth-symbol"
            size: Theme.statusIconSize
            iconColor: Theme.textMuted
            anchors.fill: parent
        }
        FontIcon {
            name: "bluetooth-left-dot"
            size: Theme.statusIconSize
            iconColor: Theme.textMuted
            anchors.fill: parent
            visible: {
                const a = Bluetooth.defaultAdapter
                return a && a.enabled
            }
        }
        FontIcon {
            name: "bluetooth-right-dot"
            size: Theme.statusIconSize
            iconColor: Theme.textMuted
            anchors.fill: parent
            visible: {
                const a = Bluetooth.defaultAdapter
                return !!(a && a.enabled)
            }
        }
    }

    Item {
        id: netIcon
        width: Theme.statusIconSize
        height: Theme.statusIconSize
        anchors.verticalCenter: parent.verticalCenter

        readonly property bool onEthernet: {
            const dev = Array.from(Networking.devices.values)
            const eth = dev.find(d => d.type === DeviceType.Wired)
            return !!(eth && eth.connected)
        }
        readonly property var wifiDev: {
            if (onEthernet) return null
            return Array.from(Networking.devices.values)
                .find(d => d.type === DeviceType.Wifi) || null
        }
        readonly property var activeNet: wifiDev
            ? Array.from(wifiDev.networks.values).find(n => n.connected) || null
            : null
        readonly property bool wifiOn: !!(wifiDev && Networking.wifiEnabled && Networking.wifiHardwareEnabled)
        readonly property bool connecting: !!(wifiDev
            && (wifiDev.state === ConnectionState.Connecting
                || wifiDev.state === ConnectionState.Disconnecting))

        FontIcon {
            name: "ethernet"
            size: Theme.statusIconSize
            iconColor: Theme.textSecondary
            anchors.fill: parent
            visible: netIcon.onEthernet
        }

        Item {
            anchors.fill: parent
            visible: !netIcon.onEthernet

            FontIcon {
                name: "wifi-none"
                size: Theme.statusIconSize
                iconColor: Theme.textMuted
                anchors.fill: parent
                visible: netIcon.wifiOn
            }
            FontIcon {
                name: "wifi-low"
                size: Theme.statusIconSize
                iconColor: Theme.textSecondary
                anchors.fill: parent
                visible: netIcon.wifiOn && netIcon.activeNet
                    && netIcon.activeNet.signalStrength >= 0.25
                    && !netIcon.connecting
            }
            FontIcon {
                name: "wifi-medium"
                size: Theme.statusIconSize
                iconColor: Theme.textSecondary
                anchors.fill: parent
                visible: netIcon.wifiOn && netIcon.activeNet
                    && netIcon.activeNet.signalStrength >= 0.50
                    && !netIcon.connecting
            }
            FontIcon {
                name: "wifi-high"
                size: Theme.statusIconSize
                iconColor: Theme.textSecondary
                anchors.fill: parent
                visible: netIcon.wifiOn && netIcon.activeNet
                    && netIcon.activeNet.signalStrength >= 0.75
                    && !netIcon.connecting
            }

        }
    }

    Item {
        width: Theme.statusIconSize
        height: Theme.statusIconSize
        anchors.verticalCenter: parent.verticalCenter

        readonly property var bat: {
            const b = UPower.displayDevice
            return (b && b.ready) ? b : null
        }
        readonly property real pct: bat ? bat.percentage : -1
        readonly property bool charging: bat
            && (bat.state === UPowerDeviceState.Charging
                || bat.state === UPowerDeviceState.FullyCharged)
        readonly property string fillGlyph: {
            if (pct < 0) return ""
            if (pct >= 0.90) return "battery-full"
            if (pct >= 0.60) return "battery-high"
            if (pct >= 0.30) return "battery-medium"
            if (pct >= 0.10) return "battery-low"
            return "" // empty
        }
        readonly property color fillColor:
            charging ? Theme.success : Theme.textSecondary

        FontIcon {
            name: "battery-track"
            size: Theme.statusIconSize
            iconColor: Theme.textMuted
            anchors.fill: parent
            visible: bat !== null
        }
        FontIcon {
            name: parent.fillGlyph
            size: Theme.statusIconSize
            iconColor: parent.fillColor
            anchors.fill: parent
            visible: parent.fillGlyph !== ""
        }
    }

    Text {
        text: Time.formatted
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.clockFontSize
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
    }
}