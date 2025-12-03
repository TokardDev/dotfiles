#!/bin/bash

# Toggle WiFi off and back on, then reconnect to WiFi@YNOV
# This helps resolve authentication issues with WiFi@YNOV

# Turn WiFi off
nmcli radio wifi off

# Wait a moment for the radio to fully disable
sleep 1

# Turn WiFi back on
nmcli radio wifi on

# Wait for WiFi to come back up
sleep 2

# Reconnect to WiFi@YNOV
nmcli connection up "WiFi@YNOV"

# Send notification (requires dunst or another notification daemon)
notify-send "WiFi Reset" "Reconnecting to WiFi@YNOV" -t 2000
