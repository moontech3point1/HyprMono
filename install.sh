#!/bin/bash

# installs everything for the hyprland setup and drops the configs into ~/.config
# run this from inside the hypr-dotfiles folder, it'll ask for sudo when it needs to

set -e

echo "before we install anything, let's set your keybinds"
echo ""

read -p "Main modifier key - Super or Alt? [Super]: " mod_choice
mod_choice=${mod_choice:-Super}

case "$mod_choice" in
    [Aa]lt)
        mainmod="ALT"
        echo "heads up, some apps already grab Alt for their own menus, so a few combos might clash"
        ;;
    *)
        mainmod="SUPER"
        ;;
esac

read -p "Key to open a terminal, used together with the modifier above [Return]: " term_key
term_key=${term_key:-Return}

echo "ok, using $mainmod + $term_key for terminal, and $mainmod for the rest of the binds"
echo ""

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

# nerd font, this one's AUR only as far as I know
yay -S --needed ttf-jetbrains-mono-nerd

mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/wofi ~/.config/mako ~/.config/kitty ~/.config/fastfetch ~/.config/cava
mkdir -p ~/Pictures/wallpapers

# hyprland moved to a lua config in 0.55, get rid of any leftover .conf so it's not just sitting there unused
rm -f ~/.config/hypr/hyprland.conf

cp -r hypr/* ~/.config/hypr/
cp -r waybar/* ~/.config/waybar/
cp -r wofi/* ~/.config/wofi/
cp -r mako/* ~/.config/mako/
cp -r kitty/* ~/.config/kitty/
cp -r fastfetch/* ~/.config/fastfetch/
cp -r cava/* ~/.config/cava/
cp -r scripts ~/.config/hypr/scripts

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

echo "done. drop a wallpaper called main.png into ~/Pictures/wallpapers and you're good to go"
echo "log out and pick Hyprland from your login manager to try it out"
