#!/usr/bin/env bash

# Check if a window with class "vesktop" exists
if hyprctl clients -j | jq -e '.[] | select(.class == "vesktop")' > /dev/null; then
    # Focus the window (this switches workspace automatically in Hyprland)
    hyprctl dispatch focuswindow "class:^vesktop$"
else
    # Launch if not found
    flatpak run dev.vencord.Vesktop
fi
