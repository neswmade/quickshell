import Quickshell
import QtQuick
import qs.services
import qs.utils
import "modules/border"
import "modules/topbar"
import "modules/notch"
import "modules/launcher"
import "modules/systemcontrols"

ShellRoot {
    FontLoader {
        source: Qt.resolvedUrl("assets/nesw.ttf")
    }

    TopBarWindow {}
    ScreenBorder {}
    NotchWindow {}
    LauncherWindow {}
    PowerControls {}
}
