#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)
DIRECTION="$1"

if [ ! -s "$DATA_FILE" ]; then
    tmux display-message "harpoon: list is empty"
    exit 0
fi

total=$(grep -c '' "$DATA_FILE")
current_session=$(tmux display-message -p '#{session_name}')
current_window_index=$(tmux display-message -p '#{window_index}')

current_slot=$(awk -F: -v session="$current_session" -v index="$current_window_index" '$1 == session && $2 == index { print NR; exit }' "$DATA_FILE")

case "$DIRECTION" in
    next)
        if [ -z "$current_slot" ]; then
            target=1
        else
            target=$((current_slot % total + 1))
        fi
        ;;
    prev)
        if [ -z "$current_slot" ]; then
            target=$total
        else
            target=$(((current_slot - 2 + total) % total + 1))
        fi
        ;;
    *)
        tmux display-message "harpoon: usage harpoon-cycle.sh <prev|next>"
        exit 1
        ;;
esac

exec "$CURRENT_DIR/harpoon-jump.sh" "$target"
