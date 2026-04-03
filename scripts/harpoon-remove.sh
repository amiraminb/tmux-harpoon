#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

session=$(tmux display-message -p '#{session_name}')
window_index=$(tmux display-message -p '#{window_index}')

pattern="${session}:${window_index}:"

if ! grep -qF "$pattern" "$DATA_FILE" 2>/dev/null; then
    tmux display-message "harpoon: not in list"
    exit 0
fi

tmp=$(mktemp)
grep -vF "$pattern" "$DATA_FILE" > "$tmp"
mv "$tmp" "$DATA_FILE"

tmux refresh-client -S
tmux display-message "harpoon: removed [${session}:${window_index}]"
