#!/usr/bin/env bash

# Toggle Bluetooth on/off and show notification

ICON_ON="bluetooth-active"
ICON_OFF="bluetooth-disabled"

# Ensure bluetooth service is running
# systemctl --user import-environment DISPLAY XAUTHORITY
# systemctl start bluetooth.service 2>/dev/null

# Function to unblock rfkill if blocked
unblock_bluetooth() {
    if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        rfkill unblock bluetooth
    fi
}

# Check current status
STATUS=$(bluetoothctl show | awk '/Powered:/ {print $2}')

if [ "$STATUS" = "yes" ]; then
    # Turn off Bluetooth
    bluetoothctl power off
    notify-send -i "$ICON_OFF" "Bluetooth" "Turned off"
else
    # Try unblocking first
    unblock_bluetooth
    sleep 1  # give BlueZ a moment
    bluetoothctl power on && \
        notify-send -i "$ICON_ON" "Bluetooth" "Turned on" || \
        notify-send -i "$ICON_OFF" "Bluetooth" "Failed to turn on"
fi
