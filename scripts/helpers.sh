#!/usr/bin/env bash

harpoon_data_file() {
    local data_dir socket_name data_file tmux_pid legacy_file window_index
    tmux_pid=$(tmux display-message -p '#{pid}')
    data_dir=$(tmux show-option -gqv @harpoon-dir 2>/dev/null)
    if [ -z "$data_dir" ]; then
        data_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux/harpoon"
    fi
    mkdir -p "$data_dir"

    socket_name=$(tmux display-message -p '#{socket_path}' 2>/dev/null)
    socket_name="${socket_name##*/}"
    [ -z "$socket_name" ] && socket_name="default"
    socket_name=$(printf '%s' "$socket_name" | tr -c '[:alnum:]_.-' '_')
    data_file="$data_dir/${socket_name}.list"

    # Migrate the old server-lifetime file while its window IDs are still valid.
    if [ ! -e "$data_file" ]; then
        legacy_file="/tmp/tmux-harpoon-${tmux_pid}"
        if [ -f "$legacy_file" ]; then
            while IFS=: read -r session window_id; do
                if [ -z "$session" ] || [ -z "$window_id" ]; then
                    continue
                fi
                window_index=$(tmux display-message -t "$window_id" -p '#{window_index}' 2>/dev/null)
                [ -n "$window_index" ] && printf '%s:%s\n' "$session" "$window_index"
            done < "$legacy_file" > "$data_file"
        fi
    fi

    touch "$data_file"
    echo "$data_file"
}
