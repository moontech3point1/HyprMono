# hypr-dotfiles

minimal/clean hyprland setup, full monochrome (grayscale only, no accent colors), heavy blur, rounded corners.

## how to use

1. unzip this wherever
2. cd into the folder
3. run `./install.sh` (it'll ask you to pick a main modifier key and terminal keybind first, then ask for your sudo password to install packages, and it'll build yay for you first if you don't already have it)
4. put a wallpaper at `~/Pictures/wallpapers/main.png` (or change the path in `hypr/hyprpaper.conf` and `hypr/hyprlock.conf`)
5. log out, pick Hyprland at your login screen

## what's in here

- `hypr/hyprland.lua` - main config, keybinds, window rules, animations (Hyprland moved to lua configs in 0.55, this replaces the old hyprland.conf)
- `hypr/hyprpaper.conf` - wallpaper
- `hypr/hyprlock.conf` - lock screen
- `hypr/hypridle.conf` - handles dimming/locking/sleep after inactivity
- `waybar/` - the top bar, now with cpu/memory, an idle inhibitor toggle, a now-playing widget, and a weather readout
- `wofi/` - app launcher (mainMod + D to open)
- `mako/` - notification popups
- `kitty/` - terminal, themed to match, with some transparency so the hyprland blur shows through
- `fastfetch/` - system info screen, runs automatically whenever you open a terminal
- `cava/` - config for the audio visualizer widget
- `scripts/cava-widget.sh` - launches the visualizer as a small pinned window in the corner of the screen

## keybinds worth knowing

the modifier key and terminal key below are whatever you picked when you ran install.sh (Super and Return by default)

- SUPER + Return = terminal
- SUPER + D = app launcher
- SUPER + Q = close window
- SUPER + E = file manager
- SUPER + V = toggle floating
- SUPER + 1-0 = switch workspace
- SUPER + SHIFT + 1-0 = move window to workspace
- Print = screenshot a region to clipboard

feel free to change anything, the colors are all just plain hex codes so they're easy to find and swap.
