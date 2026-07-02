pragma ComponentBehavior: Bound
import QtQuick

Text {
    id: root

    property string name: ""
    property int size: 24
    property color iconColor: "transparent"

    width: size
    height: size
    font.family: "nesw"
    font.pixelSize: size
    text: {
        const map = root._codepoints
        const cp = map[root.name]
        return cp ? String.fromCharCode(cp) : ""
    }
    color: root.iconColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    readonly property var _codepoints: ({
        "ethernet":             59400,
        "battery-full":         59392,
        "battery-high":         59393,
        "battery-low":          59394,
        "battery-medium":       59395,
        "battery-track":        59396,
        "bluetooth-left-dot":   59397,
        "bluetooth-right-dot":  59398,
        "bluetooth-symbol":     59399,
        "return-key":           59401,
        "search":               59402,
        "volume-body":          59403,
        "volume-max":           59404,
        "volume-medium":        59405,
        "volume-track":         59406,
        "wifi-high":            59407,
        "wifi-low":             59408,
        "wifi-medium":          59411,
        "wifi-none":            59410
    })
}