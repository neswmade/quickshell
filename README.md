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

- **BUG:** workspace ruler doesn't show "S" on special workspace. `inSpecialWs` reads `Hyprland.focusedMonitor.lastIpcObject.specialWorkspace.name` but binding doesn't update on toggle. Needs investigation - possibly `lastIpcObject` isn't reactive, may need `Hyprland.refreshMonitors()` or an event-socket signal.
- **two-tone icons:** rebuild the font with split glyphs (outline track + filled portion as separate glyphs) stack two `FontIcon`s per icon color them differently
- launcher (app search)
- power controls (logout / reboot / suspend / shutdown)

## layout

```
quickshell/
├── shell.qml              # entrypoint, mounts the three windows + FontLoader
├── utils/Theme.qml        # colors, geometry, fonts, slider constants (one singleton)
├── services/              # thin wrappers over quickshell singletons
│   ├── Audio.qml          # pipewire sink volume + mute
│   ├── Workspaces.qml     # hyprland active/occupied/special
│   └── Time.qml           # clock (ticks every second)
├── components/            # reusable widgets
│   ├── StyledSlider.qml
│   └── FontIcon.qml       # fontello glyph, color via color prop
├── modules/               # one window each
│   ├── notch/             # NotchWindow + Audio/Workspace huds
│   ├── topbar/            # TopBarWindow + StatusRow (bt/net/bat/clock)
│   └── border/
└── assets/
    └── nesw.ttf           # fontello-built icon font
```
