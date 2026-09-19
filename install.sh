#!/bin/bash

# installs everything for HyprMono and drops the configs into ~/.config
# run this from inside the repo folder, it'll ask for sudo when it needs to

set -e

# just some basic colors so the output isn't a wall of plain text, nothing fancy
BOLD="\033[1m"
GREY="\033[90m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

section() {
    echo ""
    echo -e "${BOLD}== $1 ==${RESET}"
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}HyprMono${RESET}${GREY} - minimal grayscale Hyprland setup${RESET}"

section "keybinds"

echo "hold down the key or combo you want to use as your main modifier."
echo "this needs to run as root since it reads straight from /dev/input, so you'll get a sudo prompt."
echo ""

# python-evdev does the actual raw key listening, it's in the official repos so no AUR needed here
sudo pacman -S --needed --noconfirm python-evdev > /dev/null

remap_result="$(mktemp)"
sudo python3 "$script_dir/scripts/remap-key.py" "$remap_result"
mainmod="$(cat "$remap_result")"
rm -f "$remap_result"

if [[ "$mainmod" == UNSUPPORTED:* ]]; then
    picked="${mainmod#UNSUPPORTED:}"
    echo -e "${YELLOW}heads up:${RESET} Hyprland can't actually bind a hold-modifier off $picked,"
    echo "it's not a real modifier key as far as the compositor's concerned. falling back to SUPER"
    echo "for now, you can still wire up $picked to specific binds yourself later if you want it."
    mainmod="SUPER"
elif [ "$mainmod" == "ALT" ]; then
    echo "heads up, some apps already grab Alt for their own menus, so a few combos might clash"
fi

echo -e "${GREEN}using $mainmod as the main modifier${RESET}"
echo ""

read -p "Key to open a terminal, used together with the modifier above [Return]: " term_key
term_key=${term_key:-Return}

echo "ok, using $mainmod + $term_key for terminal, and $mainmod for the rest of the binds"

section "package manager"

echo "checking for yay first since we need it for a couple AUR packages..."

if ! command -v yay &> /dev/null; then
    echo "yay not found, building it now"
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
else
    echo "yay already installed, skipping that"
fi

section "packages"

echo "installing packages, might take a bit..."

pkgs=(
    hyprland
    hyprpolkitagent
    waybar
    wofi
    mako
    hyprpaper
    hyprlock
    hypridle
    kitty
    nautilus
    grim
    slurp
    wl-clipboard
    brightnessctl
    pipewire
    wireplumber
    pavucontrol
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    networkmanager
    network-manager-applet
    fastfetch
    cava
    playerctl
)

sudo pacman -S --needed "${pkgs[@]}"

# networkmanager doesn't start itself, need to enable the service or wifi won't work
sudo systemctl enable --now NetworkManager

# aur only stuff - nerd font and the macOS style cursor theme
yay -S --needed ttf-jetbrains-mono-nerd apple_cursor

# make gtk apps (nautilus, pavucontrol, etc) use the same cursor, not just hyprland/wayland native ones
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "macOS" 2> /dev/null || true
fi

section "configs"

mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/wofi ~/.config/mako ~/.config/kitty ~/.config/fastfetch ~/.config/cava
mkdir -p ~/Pictures/wallpapers

# hyprland moved to a lua config in 0.55, get rid of any leftover .conf so it's not just sitting there unused
rm -f ~/.config/hypr/hyprland.conf

cp -r "$script_dir/hypr/"* ~/.config/hypr/
cp -r "$script_dir/waybar/"* ~/.config/waybar/
cp -r "$script_dir/wofi/"* ~/.config/wofi/
cp -r "$script_dir/mako/"* ~/.config/mako/
cp -r "$script_dir/kitty/"* ~/.config/kitty/
cp -r "$script_dir/fastfetch/"* ~/.config/fastfetch/
cp -r "$script_dir/cava/"* ~/.config/cava/
cp -r "$script_dir/scripts" ~/.config/hypr/scripts

chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh

# drop the modifier and terminal keybind picked above into the actual config
sed -i "s/local mainMod = \"SUPER\"/local mainMod = \"$mainmod\"/" ~/.config/hypr/hyprland.lua
sed -i "s/mainMod \.\. \" + \" \.\. \"Return\"/mainMod .. \" + \" .. \"$term_key\"/" ~/.config/hypr/hyprland.lua

# add fastfetch to the shell startup if it's not already there, so it runs when a terminal opens
shell_rc="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    shell_rc="$HOME/.zshrc"
fi

if ! grep -q "fastfetch" "$shell_rc" 2>/dev/null; then
    echo "" >> "$shell_rc"
    echo "fastfetch" >> "$shell_rc"
    echo "added fastfetch to $shell_rc"
else
    echo "fastfetch already wired up in $shell_rc, skipping"
fi

section "done"

echo -e "${GREEN}all set.${RESET} drop a wallpaper called main.png into ~/Pictures/wallpapers and you're good to go"
echo "log out and pick Hyprland from your login manager to try it out"
