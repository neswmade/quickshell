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
        const map = root._codepoints;
        const cp = map[root.name];
        return cp ? String.fromCharCode(cp) : "";
    }
    color: root.iconColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    readonly property var _codepoints: ({
            "wifi-none": 59392,
            "wifi-medium": 59393,
            "wifi-low": 59394,
            "wifi-high": 59395,
            "wifi-connect": 59396,
            "volume-none": 59397,
            "volume-muted": 59398,
            "volume-medium": 59399,
            "volume-max": 59400,
            "volume-low": 59401,
            "search": 59402,
            "return-key": 59403,
            "ethernet": 59404,
            "bluetooth": 59405,
            "bluetooth-off": 59406,
            "battery-medium": 59407,
            "battery-low": 59408,
            "battery-high": 59409,
            "battery-full": 59410,
            "battery-empty": 59411,
            "battery-charging": 59412
        })
}
