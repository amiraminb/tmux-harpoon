#!/usr/bin/env bash

harpoon_data_file() {
    local tmux_pid
    tmux_pid=$(tmux display-message -p '#{pid}')
    local data_file="/tmp/tmux-harpoon-${tmux_pid}"
    touch "$data_file"
    echo "$data_file"
}
