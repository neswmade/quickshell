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

- **two-tone icons:** rebuild the font with split glyphs (outline track + filled portion as separate glyphs) stack two `FontIcon`s per icon color them differently

## layout

```
quickshell/
├── shell.qml              # entrypoint, mounts all modules + FontLoader
├── utils/Theme.qml        # colors, geometry, fonts, one singleton
├── services/              # thin wrappers over quickshell singletons
│   ├── Audio.qml          # pipewire sink volume + mute
│   ├── Workspaces.qml     # hyprland active/occupied/special
│   └── Time.qml           # clock (ticks every second)
├── components/            # reusable widgets
│   ├── StyledSlider.qml
│   └── FontIcon.qml       # fontello glyph, color via color prop
├── modules/
│   ├── notch/             # notch pill + audio/workspace hud
│   ├── topbar/            # top bar + status row (bluetooth/network/battery/clock)
│   ├── border/            # screen-edge frame with rounded corners
│   ├── launcher/          # app search overlay (↑/↓/enter, IPC toggle)
│   └── systemcontrols/    # power dialog (logout/suspend/reboot/shutdown)
└── assets/
    └── nesw.ttf           # fontello-built icon font
```
