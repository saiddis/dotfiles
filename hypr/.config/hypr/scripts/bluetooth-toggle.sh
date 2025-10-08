#!/usr/bin/env bash

# Toggle Bluetooth on/off and show notification

ICON_ON="bluetooth-active"
ICON_OFF="bluetooth-disabled"

# Check current status
STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$STATUS" = "yes" ]; then
    # Turn off Bluetooth
    bluetoothctl power off
    notify-send -i "$ICON_OFF" "Bluetooth" "Turned off"
else
    # Turn on Bluetooth
    bluetoothctl power on
    notify-send -i "$ICON_ON" "Bluetooth" "Turned on"
fi
