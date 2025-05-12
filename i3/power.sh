#!/bin/sh

# Determine logout command based on session
case "$DESKTOP_SESSION" in
    i3)       logout="i3-msg exit" ;;
    hyprland) logout="killall Hyprland" ;;
    sway)     logout="swaymsg exit" ;;
    *)        logout="loginctl terminate-user $USER" ;;
esac

# Define suspend command
suspend="systemctl suspend"

# Define power menu options
options="󰍃  Log Out\n󰤄  Suspend\n󰜉  Restart\n  Power Off"

# Show rofi menu with theme
chosen=$(printf "$options" | rofi -dmenu -i -p "Power Menu" -theme-str '@import "~/.config/rofi/powermenu.rasi"')

# Perform the selected action
case "$chosen" in
    *"Log Out"*)   eval "$logout" ;;
    *"Suspend"*)   eval "$suspend" ;;
    *"Restart"*)   systemctl reboot ;;
    *"Power Off"*) systemctl poweroff ;;
    *)             exit 1 ;;
esac
