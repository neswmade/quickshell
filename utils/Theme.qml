pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property color bg: "#0a0a0a"
    readonly property color bgElevated: "#171717"
    readonly property color bgInput: "#1d1d1d"
    
    readonly property color text: "#fafafa"
    readonly property color textSecondary: "#a3a3a3"
    readonly property color textMuted: "#737373"
    
    readonly property color accent: "#009fff"
    readonly property color accentHover: "#0190e7"
    
    readonly property color error: "#ff2e3f"
    readonly property color warning: "#ffca00"
    readonly property color success: "#07c480"
    readonly property color info: "#08c0ef"

    readonly property int rounding: 24
    readonly property int borderThickness: 4
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
}