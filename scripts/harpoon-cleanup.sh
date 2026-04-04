#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    exit 0
fi

tmp=$(mktemp)
all_window_ids=$(tmux list-windows -a -F '#{window_id}' 2>/dev/null)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    window_id=$(echo "$line" | cut -d: -f2)

    if echo "$all_window_ids" | grep -qx "$window_id"; then
        echo "$line" >> "$tmp"
    fi
done < "$DATA_FILE"

mv "$tmp" "$DATA_FILE"
tmux refresh-client -S
