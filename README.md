# HyprMono

A minimal, full-grayscale Hyprland setup. No accent colors, heavy blur, rounded corners,
and a macOS style cursor. Built for Arch Linux (or anything Arch based with pacman/yay).

Why is it called HyprMono? Because, Hyprland + Monochrome = HyprMono

## What's included

- `hypr/hyprland.lua` - main config: keybinds, window rules, animations
- `hypr/hyprpaper.conf` - wallpaper
- `hypr/hyprlock.conf` - lock screen
- `hypr/hypridle.conf` - dims, locks, then sleeps after inactivity
- `waybar/` - top bar: cpu/memory, an idle inhibitor toggle, a now-playing widget, weather
- `wofi/` - app launcher
- `mako/` - notification popups
- `kitty/` - terminal, themed to match, with some transparency so the blur shows through
- `fastfetch/` - system info screen that runs when you open a terminal
- `cava/` - config for the audio visualizer widget
- `scripts/` - the visualizer launcher and the install-time key remap tool

## Requirements

- Arch Linux, or an Arch based distro using pacman
- A spare few minutes and sudo access, `install.sh` installs quite a few packages

## Install

```
git clone https://github.com/moontech3point1/HyprMono.git
cd HyprMono
./install.sh
```

The installer will:

1. Ask you to hold down the key you want as your main modifier (see below)
2. Ask what key you want paired with it to open a terminal
3. Build `yay` if you don't already have it, then install everything else
4. Copy the configs into `~/.config`

Once it's done, drop a wallpaper at `~/Pictures/wallpapers/main.png` (or change the path
in `hypr/hyprpaper.conf` and `hypr/hyprlock.conf` if you'd rather keep it somewhere else),
log out, and pick Hyprland at your login screen.

### Picking your main modifier

Instead of just typing "Super" or "Alt", the installer listens to your actual keyboard
and has you hold down whatever you want to use. Allowed picks:

Tab, Shift, Ctrl, Ctrl + Shift, Windows/Meta, Alt, Shift + Alt, Ctrl + Alt, Alt + Tab,
or your Copilot key if your keyboard has one.

It'll ask you to confirm before locking it in, and it waits for you to fully let go of
the key(s) before it moves on. Note that Tab, Alt + Tab, and the Copilot key aren't
things Hyprland can actually bind a hold-modifier to (they're not real modifier keys as
far as the compositor's concerned) - picking one of those falls back to Super, and you'd
need to wire up binds for that key by hand afterwards if you still want to use it.

## Keybinds worth knowing

The modifier and terminal key below are whatever you picked during install (Super and
Return by default).

| Bind | Action |
| --- | --- |
| Mod + Return | terminal |
| Mod + D | app launcher |
| Mod + Q | close window |
| Mod + E | file manager |
| Mod + V | toggle floating |
| Mod + 1-0 | switch workspace |
| Mod + Shift + 1-0 | move window to workspace |
| Print | screenshot a region to clipboard |

The Shift in the move window and exit binds is swapped for Ctrl if your main modifier
already has Shift in it (Shift, Ctrl + Shift, Alt + Shift), or Alt if it has Ctrl in it too.
Otherwise those binds would land on the exact same keys as the normal ones and quitting
Hyprland would end up on the same combo as closing a window.

Everything else (colors, gaps, blur amount, animation curves) is plain values in
`hypr/hyprland.lua`, easy to find and change.

## Uninstall

```
./uninstall.sh
```

This removes the Hyprland, waybar, wofi, and mako configs from `~/.config`, and takes the
`fastfetch` line back out of your shell rc file. It leaves kitty, cava, and fastfetch's
configs alone since those folders can end up with stuff in them that didn't come from
HyprMono. It also doesn't remove any packages - if you want those gone too:

```
sudo pacman -Rns hyprland waybar wofi mako hyprpaper hyprlock hypridle
```

## License

Do whatever you want with this, no warranty of any kind.
