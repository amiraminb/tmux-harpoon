#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

session=$(tmux display-message -p '#{session_name}')
window_id=$(tmux display-message -p '#{window_id}')

entry="${session}:${window_id}"

if ! grep -qx "$entry" "$DATA_FILE" 2>/dev/null; then
    tmux display-message "harpoon: not in list"
    exit 0
fi

tmp=$(mktemp)
grep -vx "$entry" "$DATA_FILE" > "$tmp"
mv "$tmp" "$DATA_FILE"

tmux refresh-client -S
tmux display-message "harpoon: removed"
