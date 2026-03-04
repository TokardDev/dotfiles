#!/usr/bin/env bash

# Check if wofi is currently running
if pgrep -x "wofi" > /dev/null; then
    # It is running. Now check if it is actually visible to the user.
    # Wofi typically appears in the 'top', 'overlay', or 'popup' layers.
    # We use grep to search for "wofi" in the entire JSON output of layers.
    if hyprctl layers -j | grep -q "wofi"; then
        # It is running AND visible. This is a toggle OFF.
        pkill -x wofi
        exit 0
    fi

    # It is running but NOT visible (stuck or glitching).
    # We kill the stuck instance and let it fall through to restart.
    pkill -x wofi
fi

# Launch wofi (Toggle ON)
# Added & to detach it, ensuring the script exits immediately
wofi --show drun --insensitive --allow-images --allow-markup &
