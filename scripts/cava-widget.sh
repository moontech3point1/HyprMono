#!/bin/bash

# this just opens cava in a tiny undecorated kitty window, the actual floating/pinning
# behavior is handled by the window rule in hyprland.lua that matches the class below

kitty --class cava-widget -o font_size=6 -o window_padding_width=4 cava
