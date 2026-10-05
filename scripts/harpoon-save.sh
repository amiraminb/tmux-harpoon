#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)
SNAPSHOT_FILE=$(harpoon_snapshot_file)

tmp=$(mktemp)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    window_id=$(echo "$line" | cut -d: -f2)
    tmux display-message -t "$window_id" -p '#{session_name}:#{window_index}' 2>/dev/null >> "$tmp"
done < "$DATA_FILE"

mv "$tmp" "$SNAPSHOT_FILE"
