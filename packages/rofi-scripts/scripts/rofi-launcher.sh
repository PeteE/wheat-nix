#!/usr/bin/env bash
rofi \
    -show combi \
    -modes combi \
    -matching fuzzy \
    -combi-modes "drun,run" \
    -combi-hide-mode-prefix \
    -drun-match-fields all \
    -drun-display-format "{name}" \
    -show-icons \
    -matching fuzzy \
    -no-drun-show-actions \
    -terminal kitty
