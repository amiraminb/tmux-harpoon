#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

tmux bind-key h switch-client -T harpoon

tmux bind-key -T harpoon a run-shell "$SCRIPTS_DIR/harpoon-add.sh"
tmux bind-key -T harpoon r run-shell "$SCRIPTS_DIR/harpoon-remove.sh"
tmux bind-key -T harpoon m display-popup -E -w 80 -h 25 "$SCRIPTS_DIR/harpoon-menu.sh"

for i in $(seq 1 9); do
    tmux bind-key "$i" run-shell "$SCRIPTS_DIR/harpoon-jump.sh $i"
done

tmux set-hook -g window-unlinked "run-shell '$SCRIPTS_DIR/harpoon-cleanup.sh'"
tmux set-hook -g after-select-window "refresh-client -S"

# tmux-resurrect allows one command per hook, so never replace one the user already set.
for hook in post-save-all:harpoon-save.sh post-restore-all:harpoon-restore.sh; do
    option="@resurrect-hook-${hook%%:*}"
    if [ -z "$(tmux show-option -gqv "$option")" ]; then
        tmux set-option -g "$option" "$SCRIPTS_DIR/${hook#*:}"
    fi
done
