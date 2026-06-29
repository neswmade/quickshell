import Quickshell
import QtQuick
import qs.services
import qs.utils
import "modules/border"
import "modules/topbar"
import "modules/notch"

ShellRoot {
    FontLoader {
        source: Qt.resolvedUrl("assets/nesw.ttf")
    }

    TopBarWindow {}
    ScreenBorder {}
    NotchWindow {}
}
