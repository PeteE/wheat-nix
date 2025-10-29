#!/usr/bin/env bash

set -euo pipefail

# Show help
show_help() {
    cat << EOF
claude-session-init - Initialize claude-sessions in a project

USAGE:
    claude-session-init [OPTIONS] [TARGET_DIRECTORY]

OPTIONS:
    -h, --help    Show this help message

ARGUMENTS:
    TARGET_DIRECTORY    Directory to initialize (defaults to current directory)

DESCRIPTION:
    This script sets up claude-sessions in your project by:
    - Copying the commands directory to .claude/commands with session management templates
    - Creating a sessions directory with .current-session subdirectory
    - Optionally adding sessions/ to your .gitignore file

EXAMPLES:
    claude-session-init                    # Initialize in current directory
    claude-session-init ~/my-project       # Initialize in specific directory
EOF
}

# Parse arguments
TARGET_DIR="."
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            break
            ;;
    esac
    shift
done

# Get the directory where this script is located (should be in the package)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_SOURCE="${SCRIPT_DIR}/commands"

# Target directories
COMMANDS_TARGET="${TARGET_DIR}/.claude/commands"
SESSIONS_TARGET="${TARGET_DIR}/sessions"
CURRENT_SESSION_TARGET="${SESSIONS_TARGET}/.current-session"

# Check if source commands directory exists
if [[ ! -d "$COMMANDS_SOURCE" ]]; then
    echo "Error: Commands directory not found at $COMMANDS_SOURCE" >&2
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

echo "🚀 Initializing claude-sessions..."

# Copy commands directory
echo "Copying commands directory..."
mkdir -p "$(dirname "$COMMANDS_TARGET")"
cp -r "$COMMANDS_SOURCE" "$COMMANDS_TARGET"

# Make copied files writable (nix store files are read-only)
chmod -R u+w "$COMMANDS_TARGET"

# Create sessions directory structure
echo "Creating sessions directory..."
mkdir -p "$CURRENT_SESSION_TARGET"

# Create .current-session file if it doesn't exist
if [[ ! -f "$SESSIONS_TARGET/.current-session" ]]; then
    touch "$SESSIONS_TARGET/.current-session"
fi

# Handle .gitignore
if [[ -f "$TARGET_DIR/.gitignore" ]]; then
    echo "Found .gitignore. Add sessions/ to it? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy] ]]; then
        if ! grep -q "^sessions/$" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            echo "" >> "$TARGET_DIR/.gitignore"
            echo "# claude-sessions" >> "$TARGET_DIR/.gitignore"
            echo "sessions/" >> "$TARGET_DIR/.gitignore"
            echo "✅ Added sessions/ to .gitignore"
        else
            echo "ℹ️  sessions/ already in .gitignore"
        fi
    fi
fi

echo "🎉 Successfully initialized claude-sessions!"
echo "Commands available in: $COMMANDS_TARGET"
echo "Sessions directory: $SESSIONS_TARGET"
