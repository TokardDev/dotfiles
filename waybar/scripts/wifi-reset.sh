#!/bin/bash

# Check if connected to WiFi@YNOV
current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

if [ "$current_ssid" = "WiFi@YNOV" ]; then
    echo "󱛅"  # Display WiFi reset icon when connected to WiFi@YNOV
else
    echo ""  # Display nothing when not connected to WiFi@YNOV
fi
