pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property var shellScreen: {
        const list = Quickshell.screens;
        for (let i = 0; i < list.length; i++) {
            if (list[i].name === "eDP-1")
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }

    readonly property color bg: "#0a0a0a"
    readonly property color bgElevated: "#171717"
    readonly property color bgInput: "#1d1d1d"

    readonly property real topBarOpacity: 0.9
    readonly property color topBarColor: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, Theme.topBarOpacity)

    readonly property color text: "#fafafa"
    readonly property color textSecondary: "#a3a3a3"
    readonly property color textMuted: "#737373"

    readonly property color accent: "#009fff"
    readonly property color accentHover: "#0190e7"

    readonly property color error: "#ff2e3f"
    readonly property color warning: "#ffca00"
    readonly property color success: "#07c480"
    readonly property color info: "#08c0ef"

    readonly property int sliderHeight: 5
    readonly property int sliderRadius: sliderHeight / 2
    readonly property color sliderTrack: bgInput
    readonly property real sliderTrackOpacity: 0.6
    readonly property color sliderFill: accent
    readonly property color sliderMuted: textMuted
    readonly property int sliderFillAnim: 80
    readonly property int sliderColorAnim: 120

    readonly property int rounding: 24
    readonly property int borderThickness: 4
    readonly property int notchHeight: 40
    readonly property int notchMinWidth: 300
    readonly property int notchMaxWidth: 360
    readonly property int notchPadding: 16
    readonly property int notchRadius: 15

    readonly property string fontFamily: "DM Sans"
    readonly property string monoFamily: "Monaspace Neon NF"

    readonly property real volumeStep: 0.05
}
