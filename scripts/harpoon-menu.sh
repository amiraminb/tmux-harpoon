#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

DATA_FILE=$(harpoon_data_file)

# State
cursor=0
cut_entry=""
last_key=""

load_entries() {
    entries=()
    if [ -f "$DATA_FILE" ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && entries+=("$line")
        done < "$DATA_FILE"
    fi
}

save_entries() {
    printf '%s\n' "${entries[@]}" > "$DATA_FILE"
}

render() {
    clear
    local total=${#entries[@]}

    printf "\033[1;36m  tmux-harpoon\033[0m"
    if [ -n "$cut_entry" ]; then
        printf "  \033[33m[cut: %s]\033[0m" "$cut_entry"
    fi
    printf "\n"
    printf "\033[2m  ─────────────────────────────\033[0m\n"

    if [ "$total" -eq 0 ]; then
        printf "\033[2m  (empty — press q to close)\033[0m\n"
        return
    fi

    for i in "${!entries[@]}"; do
        local entry="${entries[$i]}"
        local session window_index window_name
        session=$(echo "$entry" | cut -d: -f1)
        window_index=$(echo "$entry" | cut -d: -f2)
        window_name=$(echo "$entry" | cut -d: -f3-)

        local display="${session}:${window_index}"
        [ -n "$window_name" ] && display="${display} (${window_name})"

        local slot=$((i + 1))

        if [ "$i" -eq "$cursor" ]; then
            printf "\033[1;32m  %d. %s\033[0m\n" "$slot" "$display"
        else
            printf "  \033[2m%d.\033[0m %s\n" "$slot" "$display"
        fi
    done

    printf "\033[2m  ─────────────────────────────\033[0m\n"
    printf "\033[2m  j/k:move  dd:cut  p:paste  enter:jump  q:quit\033[0m\n"
}

jump_to_entry() {
    local entry="${entries[$cursor]}"
    local target_session target_window target
    target_session=$(echo "$entry" | cut -d: -f1)
    target_window=$(echo "$entry" | cut -d: -f2)
    target="${target_session}:${target_window}"

    save_entries

    if ! tmux has-session -t "$target_session" 2>/dev/null; then
        tmux display-message "harpoon: session '${target_session}' no longer exists"
        return
    fi

    current_session=$(tmux display-message -p '#{session_name}')
    if [ "$current_session" != "$target_session" ]; then
        tmux switch-client -t "$target_session"
    fi
    tmux select-window -t "$target" 2>/dev/null || \
        tmux display-message "harpoon: window ${target} no longer exists"
}

clamp_cursor() {
    local total=${#entries[@]}
    if [ "$total" -eq 0 ]; then
        cursor=0
    elif [ "$cursor" -ge "$total" ]; then
        cursor=$((total - 1))
    elif [ "$cursor" -lt 0 ]; then
        cursor=0
    fi
}

load_entries
clamp_cursor

# Hide cursor, enable alternate screen
printf "\033[?25l"
trap 'printf "\033[?25h"; save_entries' EXIT

render

while true; do
    read -rsn1 key

    # Handle escape sequences (arrow keys)
    if [ "$key" = $'\x1b' ]; then
        read -rsn2 -t 0.01 seq
        case "$seq" in
            '[A') key="k" ;;  # Up arrow
            '[B') key="j" ;;  # Down arrow
            *)    # Bare escape = quit
                break
                ;;
        esac
    fi

    case "$key" in
        j)
            last_key=""
            if [ ${#entries[@]} -gt 0 ]; then
                cursor=$(( (cursor + 1) % ${#entries[@]} ))
            fi
            ;;
        k)
            last_key=""
            if [ ${#entries[@]} -gt 0 ]; then
                cursor=$(( (cursor - 1 + ${#entries[@]}) % ${#entries[@]} ))
            fi
            ;;
        d)
            if [ "$last_key" = "d" ]; then
                # dd: cut the entry
                last_key=""
                if [ ${#entries[@]} -gt 0 ]; then
                    cut_entry="${entries[$cursor]}"
                    unset 'entries[cursor]'
                    entries=("${entries[@]}")  # reindex
                    clamp_cursor
                    save_entries
                fi
            else
                last_key="d"
            fi
            ;;
        p)
            last_key=""
            if [ -n "$cut_entry" ] && [ ${#entries[@]} -ge 0 ]; then
                # Insert after cursor position
                local_insert=$((cursor + 1))
                new_entries=()
                for i in "${!entries[@]}"; do
                    new_entries+=("${entries[$i]}")
                    if [ "$i" -eq "$cursor" ]; then
                        new_entries+=("$cut_entry")
                    fi
                done
                # If entries is empty or cursor is at end
                if [ ${#entries[@]} -eq 0 ]; then
                    new_entries=("$cut_entry")
                fi
                entries=("${new_entries[@]}")
                cursor=$((local_insert > ${#entries[@]} - 1 ? ${#entries[@]} - 1 : local_insert))
                cut_entry=""
                save_entries
            fi
            ;;
        "")
            # Enter key
            last_key=""
            if [ ${#entries[@]} -gt 0 ]; then
                jump_to_entry
                break
            fi
            ;;
        q)
            last_key=""
            break
            ;;
        *)
            last_key=""
            ;;
    esac

    render
done
