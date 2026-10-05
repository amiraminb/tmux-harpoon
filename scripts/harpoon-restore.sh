#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)
SNAPSHOT_FILE=$(harpoon_snapshot_file)

if [ ! -s "$SNAPSHOT_FILE" ]; then
    exit 0
fi

tmp=$(mktemp)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    session="${line%:*}"
    window_id=$(tmux display-message -t "=${session}:${line##*:}" -p '#{window_id}' 2>/dev/null) || continue
    echo "${session}:${window_id}" >> "$tmp"
done < "$SNAPSHOT_FILE"

mv "$tmp" "$DATA_FILE"
tmux refresh-client -S
