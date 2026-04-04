#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    echo "[H: ]"
    exit 0
fi

current_window_id=$(tmux display-message -p '#{window_id}')

items=""
slot=1
while IFS= read -r line; do
    [ -z "$line" ] && continue
    window_id=$(echo "$line" | cut -d: -f2)
    name=$(tmux display-message -t "$window_id" -p '#{window_name}' 2>/dev/null)
    if [ -z "$name" ]; then
        name="[stale]"
    fi

    if [ "$window_id" = "$current_window_id" ]; then
        items="${items}#[fg=#5e8d87,bold]${slot}:${name}#[fg=default,nobold] "
    else
        items="${items}#[fg=#7EA7C4,dim]${slot}:${name}#[fg=default,nodim] "
    fi
    slot=$((slot + 1))
done < "$DATA_FILE"

echo "[H: ${items}]"
