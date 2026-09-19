#!/bin/bash

# main menu, bound to mainMod + M in hyprland.lua. Reuses the wofi/style.css that's
# already set up for the app launcher, just fed a plain list here instead of drun
# so we can put whatever we want in it, not just installed apps.

choice=$(printf "Apps\nScreenshot\nLock\nPower" | wofi --dmenu --prompt "Menu" --width 260 --height 220)

case "$choice" in
    "Apps")
        wofi --show drun
        ;;
    "Screenshot")
        grim -g "$(slurp)" - | wl-copy
        ;;
    "Lock")
        hyprlock
        ;;
    "Power")
        # small submenu instead of dumping all four options into the main list,
        # keeps the main menu short and these are destructive enough to want
        # a second screen before picking one anyway
        power=$(printf "Suspend\nReboot\nShutdown\nLogout" | wofi --dmenu --prompt "Power" --width 260 --height 180)
        case "$power" in
            "Suspend")
                systemctl suspend
                ;;
            "Reboot")
                systemctl reboot
                ;;
            "Shutdown")
                systemctl poweroff
                ;;
            "Logout")
                hyprctl dispatch exit
                ;;
        esac
        ;;
esac
