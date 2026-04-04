#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    exit 0
fi

tmp=$(mktemp)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    session=$(echo "$line" | cut -d: -f1)
    window=$(echo "$line" | cut -d: -f2)

    if tmux has-session -t "$session" 2>/dev/null && \
       tmux list-windows -t "$session" -F '#{window_index}' 2>/dev/null | grep -qx "$window"; then
        echo "$line" >> "$tmp"
    fi
done < "$DATA_FILE"

mv "$tmp" "$DATA_FILE"
tmux refresh-client -S
