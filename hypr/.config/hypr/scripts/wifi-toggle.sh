#!/usr/bin/env bash

# Toggle Wi-Fi on/off with nmcli and show notification

ICON_ON="network-wireless-signal-excellent"
ICON_OFF="network-wireless-offline"

# Check current Wi-Fi status
STATUS=$(nmcli radio wifi)

if [ "$STATUS" = "enabled" ]; then
    # Turn off Wi-Fi
    nmcli radio wifi off
    notify-send -i "$ICON_OFF" "Wi-Fi" "Turned off"
else
    # Turn on Wi-Fi
    nmcli radio wifi on
    notify-send -i "$ICON_ON" "Wi-Fi" "Turned on"
fi
