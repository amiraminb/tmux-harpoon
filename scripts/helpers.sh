#!/usr/bin/env bash

harpoon_data_file() {
    local tmux_pid
    tmux_pid=$(tmux display-message -p '#{pid}')
    local data_file="/tmp/tmux-harpoon-${tmux_pid}"
    touch "$data_file"
    echo "$data_file"
}

# Survives server restarts, unlike the per-pid data file. Entries are session:window_index
# because window ids are reassigned when tmux-resurrect recreates the windows.
harpoon_snapshot_file() {
    local dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-harpoon"
    mkdir -p "$dir"
    echo "$dir/snapshot"
}
