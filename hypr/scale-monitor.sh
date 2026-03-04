#!/bin/bash
# Changes the scale of the currently focused (hovered) monitor
# Usage: scale-monitor.sh up|down

STEP=0.25

# Single jq call: extract focused monitor info, compute new scale, format the monitor keyword
CMD=$(hyprctl monitors -j | jq -r --arg dir "$1" --argjson step "$STEP" '
  [.[] | select(.focused)][0] |
  (if $dir == "up" then [(.scale + $step), 3] | min
   else [(.scale - $step), 0.5] | max end) as $new |
  "\(.name),\(.width)x\(.height)@\(.refreshRate),\(.x)x\(.y),\($new)"
')

hyprctl keyword monitor "$CMD"
