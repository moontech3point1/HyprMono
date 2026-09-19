#!/bin/bash

# removes the configs HyprMono's install.sh put in place. doesn't touch packages,
# since some of them (kitty, nautilus, etc) you might still want even without HyprMono

set -e

BOLD="\033[1m"
GREEN="\033[32m"
RESET="\033[0m"

echo -e "${BOLD}HyprMono uninstall${RESET}"
echo "this removes ~/.config/hypr, waybar, wofi, mako, and the fastfetch line from your shell rc."
echo "it will NOT remove kitty, cava, or fastfetch configs, since those folders might have"
echo "stuff in them that isn't from HyprMono - remove those by hand if you want them gone too."
echo ""

read -p "continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "ok, not touching anything"
    exit 0
fi

rm -rf ~/.config/hypr
rm -rf ~/.config/waybar
rm -rf ~/.config/wofi
rm -rf ~/.config/mako

# pull the fastfetch line back out of whichever shell rc install.sh added it to
for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_rc" ] && grep -q "^fastfetch$" "$shell_rc"; then
        sed -i '/^fastfetch$/d' "$shell_rc"
        echo "removed the fastfetch line from $shell_rc"
    fi
done

echo ""
echo -e "${GREEN}done.${RESET} you'll want to pick a different session at your login screen next time,"
echo "hyprland itself and the packages are still installed - remove those with pacman/yay if you want"
echo "them gone completely, something like:"
echo ""
echo "  sudo pacman -Rns hyprland waybar wofi mako hyprpaper hyprlock hypridle"
echo ""
