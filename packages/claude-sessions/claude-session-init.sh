#!/usr/bin/env bash

set -euo pipefail

# Default target directory is current directory
TARGET_DIR="${1:-.}"

# Get the directory where this script is located (should be in the package)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_SOURCE="${SCRIPT_DIR}/commands"

# Target directory for commands
COMMANDS_TARGET="${TARGET_DIR}/commands"

# Check if source commands directory exists
if [[ ! -d "$COMMANDS_SOURCE" ]]; then
    echo "Error: Commands directory not found at $COMMANDS_SOURCE" >&2
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy commands directory
echo "Copying commands directory to $COMMANDS_TARGET..."
cp -r "$COMMANDS_SOURCE" "$COMMANDS_TARGET"

echo "Successfully initialized claude-sessions in $TARGET_DIR"
echo "Commands available in: $COMMANDS_TARGET"
