# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Waybar configuration directory for a Wayland compositor (likely Hyprland based on the module usage). Waybar is a highly customizable status bar for Wayland compositors.

## File Structure

- **config**: Main JSON configuration file that defines module layout, behavior, and commands
- **style.css**: Primary stylesheet that imports macchiato.css and defines visual appearance
- **macchiato.css**: Custom color palette CSS variables (dark blue theme based on Catppuccin Macchiato)

## Configuration Architecture

### Module Layout (config file)
- **Left**: User group and Hyprland workspaces
- **Center**: Custom music player widget
- **Right**: Audio, backlight, battery, system tray, lock/reboot button, power button

### Key Dependencies
- `playerctl`: Used for music metadata display (config:31)
- `pavucontrol`: Launched for audio control (config:64)
- Font: FantasqueSansMono Nerd Font required for icons and proper display (style.css:4)

### Color System
All colors are defined as CSS variables in macchiato.css using `@define-color`. The style.css file references these with `@` prefix (e.g., `@surface0`, `@lavender`). When modifying colors, edit macchiato.css variables rather than hardcoding values.

## Testing Changes

After modifying configuration files, reload Waybar:
```bash
killall waybar && waybar &
```

Or if using a process manager:
```bash
pkill waybar; waybar > /dev/null 2>&1 &
```

## Common Modifications

- **Adding modules**: Add to modules-left/center/right arrays in config, then style in style.css
- **Adjusting colors**: Modify @define-color variables in macchiato.css
- **Module spacing/padding**: Edit padding and margin values in style.css (typically 0.5rem 1rem)
- **Border radius**: Consistently uses 1rem for rounded corners throughout
