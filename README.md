# nesw quickshell

opinionated Hyprland shell built on [Quickshell](https://quickshell.outfoxxed.me).
dark, quiet, laptop-first. pierre color scheme.

## install

```bash
mv ~/.config/quickshell ~/.config/quickshell.bak
git clone https://github.com/neswmade/quickshell.git ~/.config/quickshell
qs -c quickshell
```

## dependencies

- `quickshell-git` — the shell runtime, needs the git version not the tagged release
- `hyprland` — window manager + IPC (workspaces, dispatch)
- `pipewire` — audio
- `qt6-base` `qt6-declarative` — QML + QtQuick.Shapes

fonts:

- `dm-sans` — UI
- `monaspace-neon-nerd-font` — mono (currently unused, reserved for later)

## what's here

- **notch** — top-center pill. expands on volume change or workspace switch, collapses after a beat.
- **topbar** — slim bar hugging the top corners, sits under the notch.
- **border** — screen-edge frame with rounded bottom corners.

## to-do

- launcher (app search)
- status bar — clock, battery, network, bluetooth
- power controls (logout / reboot / suspend / shutdown)
- fontello icon font to replace the temp svg tinting

## layout

```
quickshell/
├── shell.qml              # entrypoint, mounts the three windows
├── utils/Theme.qml        # colors, geometry, fonts, slider constants (one singleton)
├── services/             # thin wrappers over quickshell singletons
│   ├── Audio.qml          # pipewire sink volume + mute
│   └── Workspaces.qml     # hyprland active/occupied/special
├── components/            # reusable widgets
│   ├── StyledSlider.qml
│   └── SvgIcon.qml        # temp, see to-do
├── modules/               # one window each
│   ├── notch/             # NotchWindow + Audio/Workspace huds
│   ├── topbar/
│   └── border/
└── assets/                # svgs (temp until fontello)
```

single monitor (hardcoded `eDP-1`). multi-monitor via `Quickshell.Variants` later if anyone asks.
