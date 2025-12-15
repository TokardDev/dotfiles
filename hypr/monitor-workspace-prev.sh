#!/bin/bash
# Switch to the previous workspace on the current monitor
# Does not loop around - stays at first workspace

# Given an element and an array, return the index of the element
array_index() {
    local element=$1
    shift
    local array=($@)
    for i in ${!array[@]}; do
        if [[ ${array[$i]} -eq $element ]]; then
            echo $i
            return 0
        fi
    done
    return 1
}

# Get the current workspace ID
current_workspace=$(hyprctl activeworkspace -j | jq '.id')

# Get the current monitor ID
focused_monitor=$(hyprctl activeworkspace -j | jq '.monitorID')

# Get a list of all workspace IDs on the current monitor, sorted numerically
workspaces=($(hyprctl workspaces -j | jq ".[] | select(.monitorID == ${focused_monitor}).id" | sort -n))

# Find the previous existing workspace ID
index=$(array_index $current_workspace ${workspaces[@]})

# If a lower workspace exists, switch to it
if [[ $index -ne 0 ]]; then
    hyprctl dispatch workspace ${workspaces[$index-1]}
fi
