#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") <albums-dir>

Copy each subdirectory of <albums-dir> to a matching Google Photos album
via the "gphotos" rclone remote (gphotos:album/<name>).

Example:
  $(basename "$0") /Volumes/media/backup/Marianne/pics/albums

Already-uploaded files are skipped by rclone (filename match), so it's
safe to re-run after a partial/interrupted run.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -eq 0 ]]; then
    usage
    exit 0
fi

albums_dir="$1"

if [[ ! -d "$albums_dir" ]]; then
    echo "error: not a directory: $albums_dir" >&2
    exit 1
fi

cd "$albums_dir"
for dir in */; do
    name="${dir%/}"
    echo "=== $name ==="
    rclone copy "$name" "gphotos:album/$name" --progress
done
