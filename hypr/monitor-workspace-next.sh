#!/bin/bash
# Switch to the next workspace on the current monitor
# Creates a new blank workspace if at the end

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

# Find the next existing workspace ID
index=$(array_index $current_workspace ${workspaces[@]})
next_workspace=${workspaces[$index+1]}

# If no higher workspace exists, create a new one
if [[ -z $next_workspace ]]; then
    # But don't create a workspace if the current one is empty
    active_window=$(hyprctl activeworkspace -j | jq -r '.lastwindow')
    if [[ $active_window != "0x0" ]]; then
        hyprctl dispatch workspace emptynm
    fi
# Else switch to the next workspace
else
    hyprctl dispatch workspace $next_workspace
fi
