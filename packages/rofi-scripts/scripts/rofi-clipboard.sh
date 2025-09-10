#!/usr/bin/env bash

# Rofi clipboard manager using clipcat
# Usage:
#   rofi-clipboard           # Launch rofi clipboard menu
#   rofi-clipboard --modi    # Modi mode (used internally by rofi)

if [ "$1" = "--modi" ]; then
    # Modi mode: handle rofi's list/select protocol
    if [ $# -eq 1 ]; then
        # List mode - show clipboard history
        clipcatctl list
    else
        # Selection mode - user selected an item from the list
        selected_line="$2"
        
        # Extract the ID (first part before the colon)
        clip_id=$(echo "$selected_line" | cut -d':' -f1)
        
        # Promote this item to current clipboard (suppress output)
        clipcatctl promote "$clip_id" > /dev/null 2>&1
    fi
else
    # Default: launch rofi clipboard menu
    rofi \
        -modi "clipboard:$0 --modi" \
        -show clipboard \
        -width 1000
fi
