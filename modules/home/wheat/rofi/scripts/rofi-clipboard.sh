#!/usr/bin/env bash
rofi \
    -modi "clipboard:greenclip print" \
    -show clipboard \
    -run-command '{cmd}' \
    -width 1000 \
	-theme "$HOME"/.config/rofi/clipboard.rasi
