#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)
SLOT="$1"

if [ -z "$SLOT" ]; then
    tmux display-message "harpoon: no slot specified"
    exit 1
fi

entry=$(sed -n "${SLOT}p" "$DATA_FILE")

if [ -z "$entry" ]; then
    tmux display-message "harpoon: slot ${SLOT} is empty"
    exit 0
fi

target_session=$(echo "$entry" | cut -d: -f1)
target_window=$(echo "$entry" | cut -d: -f2)
target="${target_session}:${target_window}"

if ! tmux has-session -t "$target_session" 2>/dev/null; then
    tmux display-message "harpoon: session '${target_session}' no longer exists"
    exit 0
fi

if ! tmux select-window -t "$target" 2>/dev/null; then
    tmux display-message "harpoon: window ${target} no longer exists"
    exit 0
fi

current_session=$(tmux display-message -p '#{session_name}')
if [ "$current_session" != "$target_session" ]; then
    tmux switch-client -t "$target"
fi
