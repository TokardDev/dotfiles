#!/usr/bin/env bash

set -e

# Get the list of monitors in JSON format using hyprctl
monitors_json=$(hyprctl monitors -j)

# Get the list of workspaces in JSON format using hyprctl
workspaces_json=$(hyprctl workspaces -j)

# Extract the monitor names and IDs from the JSON data
monitors=($(echo $monitors_json | jq -r '. | sort_by(.x) | .[].name'))

# Extract the monitor IDs from the JSON data
ids=($(echo $monitors_json | jq -r '. | sort_by(.x) | .[].id'))

function get_current_workspace() {
  current_workspace=($(hyprctl monitors -j | jq ".[?] | select(.id == $1 ) | .activeWorkspace.id"))
  echo $current_workspace
}

function get_list_of_workspaces() {
  workspaces=($(hyprctl workspaces -j | jq ".[?] | select(.monitorID == $1 ) | .id"))
  echo "${workspaces[@]}"
}

function findIndex() {
  local target=$1
  shift
  local arr=("$@")
  local index=-1
  for i in "${!arr[@]}"; do
    if [[ "${arr[$i]}" == "$target" ]]; then
      index=$i
      break
    fi
  done
  echo $index
}

function findNextWorkspace() {
  local monitor=$1
  local workspaces=($(get_list_of_workspaces ${monitor}))
  local current_workspace=$(get_current_workspace ${monitor})
  local index=$(findIndex $current_workspace ${workspaces[@]})

  if [[ $index -eq -1 ]]; then
    echo ""
    return 1
  else
    if [[ $index -eq $((${#workspaces[@]} - 1)) ]]; then
      local next_index=${index}
    else
      local next_index=$((index + 1))
    fi
    next_workspace=${workspaces[$next_index]}
    echo $next_workspace
    return 0
  fi
}

function findPreviousWorkspace() {
  local monitor=$1
  local workspaces=($(get_list_of_workspaces ${monitor}))
  local current_workspace=$(get_current_workspace ${monitor})
  local index=$(findIndex $current_workspace ${workspaces[@]})

  if [[ $index -eq -1 ]]; then
    echo ""
    return 1
  else
    if [[ $index -eq 0 ]]; then
      local prev_index=${index}
    else
      local prev_index=$((index - 1))
    fi
    prev_workspace=${workspaces[$prev_index]}
    echo $prev_workspace
    return 0
  fi
}

function findFirstWorkspace() {
  local monitor=$1
  local workspaces=($(get_list_of_workspaces ${monitor}))
  echo ${workspaces[0]}
}

function findLastWorkspace() {
  local monitor=$1
  local workspaces=($(get_list_of_workspaces ${monitor}))
  echo ${workspaces[$((${#workspaces[@]} - 1))]}
}

function moveAllWorkspaces() {
  local direction=$1
  case "${direction}" in
    prev)
      func=findPreviousWorkspace
      ;;
    next)
      func=findNextWorkspace
      ;;
    last)
      func=findLastWorkspace
      ;;
    first)
      func=findFirstWorkspace
      ;;
    *)
      return 1
      ;;
  esac

  for m in "${ids[@]}"; do
    echo "Moving workspace $m to ${direction} workspace"
    local workspace=$(${func} $m)
    hyprctl dispatch workspace ${workspace} > /dev/null
  done
}

cli_help() {
  cat <<EOF
Usage: $0 [prev|next|first|last]

Moves simultaneously all workspaces to the previous or next one for all monitors.
This script is intended to be used with Hyprland.

Options:
  prev: Move all workspaces to the previous workspace
  next: Move all workspaces to the next workspace
  first: Move all workspaces to the first workspace
  last: Move all workspaces to the last workspace
EOF
}

case "$1" in
  prev)
    moveAllWorkspaces prev
    ;;
  next)
    moveAllWorkspaces next
    ;;
  last)
    moveAllWorkspaces last
    ;;
  first)
    moveAllWorkspaces first
    ;;
  *)
    cli_help
    ;;
esac
