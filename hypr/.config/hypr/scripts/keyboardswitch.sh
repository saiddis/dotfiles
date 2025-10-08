#!/usr/bin/env bash

# Switch keyboard layout
hyprctl switchxkblayout all next

# Get current layout
layMain=$(hyprctl -j devices \
    | jq -r '.keyboards[] | select(.main == true).active_keymap')

# Send notification with GTK icon
notify-send -r 91190 -t 800 -i "input-keyboard" "  ${layMain}"
