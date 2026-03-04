#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0"
STATE_FILE="/tmp/hypr-battery-prev-brightness"
LOW_LEVEL=20
CRITICAL_LEVEL=10
DIM_LOW="20%"
DIM_CRITICAL="5%"

# Function to get current brightness
get_brightness() {
    brightnessctl g
}

# Function to set brightness
set_brightness() {
    brightnessctl -e4 set "$1"
}

check_and_apply() {
    if [ ! -d "$BATTERY_PATH" ]; then return; fi

    STATUS=$(cat "$BATTERY_PATH/status")
    CAPACITY=$(cat "$BATTERY_PATH/capacity")

    # Read previous state if it exists
    if [ -f "$STATE_FILE" ]; then
        IS_DIMMED=true
        SAVED_VAL=$(cat "$STATE_FILE")
    else
        IS_DIMMED=false
        SAVED_VAL=""
    fi

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$CAPACITY" -le "$CRITICAL_LEVEL" ]; then
            # CRITICAL
            if [ ! -f "$STATE_FILE" ]; then
                # First time dimming, save current brightness
                get_brightness > "$STATE_FILE"
                notify-send -u critical "Battery Critical" "Battery at ${CAPACITY}%. Dimming screen."
            elif [ "$IS_DIMMED" = "true" ]; then
                 # Already dimmed, but maybe we need to go LOWER (Low -> Critical)
                 # We don't want to re-save the already dimmed value.
                 # Just ensure we are at critical brightness.
                 # Check if we should notify again (optional, to avoid spam)
                 # Simple heuristic: Just set it.
                 pass
            fi
            
            # Enforce critical brightness
            # We avoid constantly resetting it if the user manually adjusted it?
            # For critical battery, we probably want to enforce it.
            # But let's avoid spamming the set command every second.
            # We can't easily know if we are "at critical brightness" vs "user raised it".
            # For now, we enforce it on every event (change).
            set_brightness "$DIM_CRITICAL"

        elif [ "$CAPACITY" -le "$LOW_LEVEL" ]; then
            # LOW
            if [ ! -f "$STATE_FILE" ]; then
                # Save current
                get_brightness > "$STATE_FILE"
                notify-send -u normal "Battery Low" "Battery at ${CAPACITY}%. Dimming screen."
                set_brightness "$DIM_LOW"
            else
                # Already dimmed.
                # If we were Critical and charged up to Low (unlikely without AC), do nothing.
                # If we were High and dropped to Low, we saved.
                # We just ensure brightness is low.
                # To allow manual override, maybe we shouldn't force it continuously?
                # But the user wants "reduce automatically".
                # Let's only set it if we *just* transitioned? 
                # Hard to track transition without memory. 
                # Simpler: If the file was just created? No.
                
                # Compromise: We set it. If user fights it, they fight it.
                # But to avoid 'set' spam on every % drop:
                # We could store "current_mode" in another temp file.
                pass
            fi
            
            # Just ensure we are at least dimmed? 
            # If we enforce every loop, user cannot raise brightness temporarily.
            # Let's ONLY set brightness if we are SAVING it (transitioning).
            # OR if we cross the threshold.
            
            # Revised logic for "Do not fight user":
            # Only set brightness when we transitions from >20 to <=20.
            # But since we don't track history easily, we rely on the existence of the file.
            # If file didn't exist -> We just transitioned -> Set brightness.
            # If file exists -> We are already in low mode -> Do NOT touch brightness (respect user override).
            pass
        fi

    else
        # CHARGING / FULL
        if [ -f "$STATE_FILE" ]; then
            SAVED_VAL=$(cat "$STATE_FILE")
            # Sanity check: ensure saved val is valid number
            if [[ "$SAVED_VAL" =~ ^[0-9]+$ ]]; then
                set_brightness "$SAVED_VAL"
                notify-send -u normal "Power Connected" "Restoring brightness."
            fi
            rm -f "$STATE_FILE"
        fi
    fi
}

# Run once on startup
check_and_apply

# Monitor for changes
# We monitor both upower (events) and have a slow fallback poll?
# upower --monitor should catch all capacity changes too.
upower --monitor | while read -r line; do
    check_and_apply
done