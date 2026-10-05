#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    exit 0
fi

tmp=$(mktemp)
all_windows=$(tmux list-windows -a -F '#{session_name}:#{window_index}' 2>/dev/null)
while IFS= read -r line; do
    [ -z "$line" ] && continue

    if printf '%s\n' "$all_windows" | grep -Fqx "$line"; then
        echo "$line" >> "$tmp"
    fi
done < "$DATA_FILE"

mv "$tmp" "$DATA_FILE"
tmux refresh-client -S
