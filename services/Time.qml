// clock singleton — ticks every second, exposes a formatted string.
// ponytail: no locale config yet, hard-coded English short format. Add i18n
// when someone needs it.
pragma Singleton
import QtQuick

QtObject {
    id: root

    property date now: new Date()

    readonly property var _days: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var _months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    readonly property string formatted: {
        const d = root.now
        let h = d.getHours()
        const ampm = h >= 12 ? "PM" : "AM"
        h = h % 12
        if (h === 0) h = 12
        const mm = String(d.getMinutes()).padStart(2, "0")
        return root._days[d.getDay()] + " " + root._months[d.getMonth()] + " "
            + d.getDate() + "  " + h + ":" + mm + " " + ampm
    }

    function _tick() { root.now = new Date() }

    readonly property Timer _timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._tick()
    }
}
