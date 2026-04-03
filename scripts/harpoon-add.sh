#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

session=$(tmux display-message -p '#{session_name}')
window_index=$(tmux display-message -p '#{window_index}')
window_name=$(tmux display-message -p '#{window_name}')

entry="${session}:${window_index}:${window_name}"

if grep -qF "${session}:${window_index}:" "$DATA_FILE" 2>/dev/null; then
    tmux display-message "harpoon: already added"
    exit 0
fi

echo "$entry" >> "$DATA_FILE"
tmux refresh-client -S
tmux display-message "harpoon: added [${session}:${window_index}] ${window_name}"
