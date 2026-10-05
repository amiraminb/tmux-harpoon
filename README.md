# tmux-harpoon

Quickly bookmark and jump between tmux windows.
Inspired by [ThePrimeagen's harpoon](https://github.com/ThePrimeagen/harpoon) for neovim.

## Features

- Add/remove tmux windows to a quick-access list
- Jump to any bookmarked window by slot number (across sessions)
- Cycle to the previous/next bookmark, wrapping around
- Interactive floating popup menu with vim-style keybindings
- Cut and paste to rearrange entries (`dd` / `p` / `P`)
- Clickable status bar integration
- Closed windows are removed from the list automatically
- Survives tmux server restarts when used with tmux-resurrect

## Requirements

- tmux 3.2+ (for `display-popup` support)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) (optional, for persistence across server restarts)

## Installation

Clone the repo:

```bash
git clone https://github.com/amiraminb/tmux-harpoon.git ~/.config/tmux/plugins/tmux-harpoon
```

Add to your `tmux.conf`, after tmux-resurrect is loaded if you use it:

```bash
run-shell "~/.config/tmux/plugins/tmux-harpoon/harpoon.tmux"
```

Reload tmux:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## Keybindings

| Binding | Action |
|---|---|
| `prefix` `h` `a` | Add current window to harpoon |
| `prefix` `h` `r` | Remove current window from harpoon |
| `prefix` `h` `m` | Open harpoon menu |
| `prefix` `1-9` | Jump to harpoon slot 1-9 |

Menu keys: `j`/`k` or arrows to move, `Enter` to jump, `dd` to cut, `p` to paste
below, `P` to paste above, `q` or `Esc` to close. Every change is saved
immediately.

### Cycling

`scripts/harpoon-cycle.sh next|prev` jumps to the next or previous bookmark and
wraps around. The plugin does not bind it, so add your own keys:

```bash
bind -n S-Left run-shell "/path/to/tmux-harpoon/scripts/harpoon-cycle.sh prev"
bind -n S-Right run-shell "/path/to/tmux-harpoon/scripts/harpoon-cycle.sh next"
```

## Status Bar

Add the status script to your `status-left` or `status-right`, and pass
`#{window_id}` so the current window is resolved per client at draw time:

```bash
set -g status-right "#(/path/to/tmux-harpoon/scripts/harpoon-status.sh #{window_id})"
```

The current window is orange (`#E6A07A`), others are grey (`#8B949E`). Each item
is a status range named `h1` to `h9`, so it can be clicked. The plugin does not
bind the click, so add this with `set -g mouse on`:

```bash
bind -T root MouseDown1Status if-shell -F '#{m/r:^h[1-9]$,#{mouse_status_range}}' {
    run-shell "/path/to/tmux-harpoon/scripts/harpoon-jump.sh #{s/^h//:#{mouse_status_range}}"
} {
    switch-client -t =
}
```

## How it stores bookmarks

- **Live list:** `/tmp/tmux-harpoon-<tmux server pid>`, one `session:window_id`
  per line. Window ids do not change when windows are renumbered, so bookmarks
  stay correct with `renumber-windows on`.
- **Snapshot:** on tmux-resurrect's `post-save-all` hook, `harpoon-save.sh`
  writes `session:window_index` lines to
  `${XDG_STATE_HOME:-~/.local/state}/tmux-harpoon/snapshot`. On `post-restore-all`,
  `harpoon-restore.sh` maps them to the new window ids.
- **Hooks:** `harpoon.tmux` only sets a resurrect hook if you have not set one.
  Combine the scripts yourself if you already use these hooks.
- **Limit:** changes made since the last resurrect save are lost if the server
  stops without a save (for example with tmux-continuum, up to one save
  interval).
- **Cleanup:** a `window-unlinked` hook runs `harpoon-cleanup.sh` to drop entries
  for closed windows.
