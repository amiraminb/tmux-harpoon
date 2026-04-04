#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    echo "[H: ]"
    exit 0
fi

current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')

items=""
slot=1
while IFS= read -r line; do
    [ -z "$line" ] && continue
    session=$(echo "$line" | cut -d: -f1)
    window=$(echo "$line" | cut -d: -f2)
    name=$(tmux display-message -t "${session}:${window}" -p '#{window_name}' 2>/dev/null)
    if [ -z "$name" ]; then
        name="[stale]"
    fi

    if [ "$session" = "$current_session" ] && [ "$window" = "$current_window" ]; then
        items="${items}#[fg=#5e8d87,bold]${slot}:${name}#[fg=default,nobold] "
    else
        items="${items}#[fg=#7EA7C4,dim]${slot}:${name}#[fg=default,nodim] "
    fi
    slot=$((slot + 1))
done < "$DATA_FILE"

echo "[H: ${items}]"
