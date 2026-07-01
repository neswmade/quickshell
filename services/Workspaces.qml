pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property int activeWs: Math.max(1, Hyprland.focusedWorkspace?.id ?? 1)

    readonly property int maxOccupied: {
        let m = 0;
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].id > m)
                m = list[i].id;
        }
        return m;
    }

    readonly property var occupied: {
        const s = {};
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].id > 0)
                s[list[i].id] = true;
        }
        return s;
    }

    function inSpecialWs(screen) {
        const mon = Hyprland.monitorFor(screen);
        if (!mon)
            return false;
        const special = mon.lastIpcObject.specialWorkspace;
        const name = special ? (special.name ?? "") : "";
        return name.length > 0;
    }

    property Connections _hyprlandConn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecialv2")
                Hyprland.refreshMonitors();
        }
    }
}