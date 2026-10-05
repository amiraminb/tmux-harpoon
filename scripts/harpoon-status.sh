#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

if [ ! -s "$DATA_FILE" ]; then
    exit 0
fi

# Prefer the window id passed by the status-line format (#{window_id}), which
# tmux resolves per-client at draw time. Falling back to `display-message` here
# is unreliable because the status `#()` shell has no associated client, so it
# can resolve to the wrong window (e.g. after a `_popup` overlay closes).
current_window_id="${1:-$(tmux display-message -p '#{window_id}')}"

items=""
slot=1
while IFS= read -r line; do
    [ -z "$line" ] && continue
    session=$(echo "$line" | cut -d: -f1)
    window_id=$(echo "$line" | cut -d: -f2)
    name=$(tmux display-message -t "$window_id" -p '#{window_name}' 2>/dev/null)
    if [ -z "$name" ]; then
        name="[stale]"
    fi

    label="${slot}:[${session}]${name}"
    if [ "$window_id" = "$current_window_id" ]; then
        items="${items}#[range=user|h${slot}]#[fg=#E6A07A]${label}#[fg=default]#[norange] "
    else
        items="${items}#[range=user|h${slot}]#[fg=#8B949E]${label}#[fg=default]#[norange] "
    fi
    slot=$((slot + 1))
done < "$DATA_FILE"

echo "${items% }"
