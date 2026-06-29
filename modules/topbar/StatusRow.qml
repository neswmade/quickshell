// top-right cluster: bluetooth, network, battery, clock.
// read-only glyphs + time text. No service wrappers — these are displays,
// not reusable logic. If a click-action layer lands later, split each into
// its own component then.
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

    spacing: 20

    // ---- bluetooth ----
    FontIcon {
        name: {
            const a = Bluetooth.defaultAdapter
            if (!a || !a.enabled) return "bluetooth-off"
            return "bluetooth"
        }
        size: 20
        iconColor: Theme.textSecondary
        anchors.verticalCenter: parent.verticalCenter
    }

    // ---- network (ethernet wins over wifi) ----
    FontIcon {
        name: {
            const dev = Array.from(Networking.devices.values)
            const eth = dev.find(d => d.type === DeviceType.Wired)
            if (eth && eth.connected) return "ethernet"
            const wifi = dev.find(d => d.type === DeviceType.Wifi)
            if (!wifi || !Networking.wifiEnabled || !Networking.wifiHardwareEnabled)
                return "wifi-none"
            const active = Array.from(wifi.networks.values).find(n => n.connected)
            if (!active) return "wifi-none"
            if (wifi.state === ConnectionState.Connecting
                || wifi.state === ConnectionState.Disconnecting)
                return "wifi-connect"
            const s = active.signalStrength
            if (s >= 0.75) return "wifi-high"
            if (s >= 0.50) return "wifi-medium"
            return "wifi-low"
        }
        size: 20
        iconColor: Theme.textSecondary
        anchors.verticalCenter: parent.verticalCenter
    }

    // ---- battery ----
    FontIcon {
        name: {
            const b = UPower.displayDevice
            if (!b || !b.ready) return "battery-empty"
            const p = b.percentage
            if (b.state === UPowerDeviceState.Charging
                || b.state === UPowerDeviceState.FullyCharged)
                return "battery-charging"
            if (p >= 0.90) return "battery-full"
            if (p >= 0.60) return "battery-high"
            if (p >= 0.30) return "battery-medium"
            if (p >= 0.10) return "battery-low"
            return "battery-empty"
        }
        size: 20
        iconColor: Theme.textSecondary
        anchors.verticalCenter: parent.verticalCenter
    }

    // ---- clock ----
    Text {
        text: Time.formatted
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 15
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
    }
}
