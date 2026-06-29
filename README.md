# nesw quickshell
## install

```bash
mv ~/.config/quickshell ~/.config/quickshell.bak
git clone https://github.com/neswmade/quickshell.git ~/.config/quickshell
qs -c quickshell
```

## dependencies

- `quickshell-git`
- `hyprland`
- `pipewire`
- `qt6-base` `qt6-declarative`
- `dm-sans` (font)
- `monaspace-neon-nerd-font` (font)

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
├── services/              # thin wrappers over quickshell singletons
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