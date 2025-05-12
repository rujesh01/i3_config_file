#!/bin/bash

# Get list of Wi-Fi networks with required fields
wifi_list=$(nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list | awk -F: '!seen[$2]++')

# Check if list is empty
[ -z "$wifi_list" ] && notify-send "Wi-Fi" "No networks found" && exit 1

# Format for rofi display
formatted_list=$(echo "$wifi_list" | while IFS=: read -r active ssid security signal; do
    # Show a padlock icon if network is secured
    if [[ "$security" == "--" ]]; then
        lock="󰌾"  # unlocked
    else
        lock=""  # locked
    fi

    # Show signal icon
    if [ "$signal" -ge 80 ]; then
        bars="󰤨"  # full signal
    elif [ "$signal" -ge 60 ]; then
        bars="󰤥"  # good signal
    elif [ "$signal" -ge 40 ]; then
        bars="󰤢"  # medium signal
    else
        bars="󰤟"  # weak signal
    fi

    # Mark active connection
    if [[ "$active" == "*" ]]; then
        ssid="$ssid (connected)"
    fi

    # Format SSID with lock and signal icon
    echo -e "$ssid\t$lock $bars $signal%"
done)

# Show selection menu with Rofi
chosen=$(echo -e "$formatted_list" | rofi -dmenu -i -p "Select Wi-Fi" -columns 1 -width 50 -lines 10 | cut -f1 | sed 's/ (connected)//')

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

# Check if the selected SSID is secured
security=$(nmcli -t -f SSID,SECURITY dev wifi list | grep -F "$chosen:" | head -n1 | cut -d: -f2)

# Prompt for password if needed
if [[ "$security" != "--" && "$security" != "" ]]; then
    password=$(rofi -dmenu -p "Password for $chosen" -password)
    [ -z "$password" ] && exit 1
    nmcli dev wifi connect "$chosen" password "$password"
else
    nmcli dev wifi connect "$chosen"
fi

# Show result notification
if [ $? -eq 0 ]; then
    notify-send "Wi-Fi" "Connected to $chosen"
else
    notify-send "Wi-Fi" "Failed to connect to $chosen"
fi
