# tmux-harpoon

Quickly bookmark and jump between tmux windows — inspired by [ThePrimeagen's harpoon](https://github.com/ThePrimeagen/harpoon) for neovim.

## Features

- Add/remove tmux windows to a quick-access list
- Jump to any bookmarked window by slot number (across sessions)
- Interactive floating popup menu with vim-style keybindings
- Cut and paste to rearrange entries (`dd` / `p`)
- Session-lifetime persistence (resets when tmux server restarts)

## Requirements

- tmux 3.2+ (for `display-popup` support)

## Installation

Clone the repo:

```bash
git clone https://github.com/YOUR_USER/tmux-harpoon.git ~/dev/personal/tmux-harpoon
```

Add to your `tmux.conf`:

```bash
run-shell "/path/to/tmux-harpoon/harpoon.tmux"
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
| `prefix` `1-9` | Jump to harpoon slot 1–9 |
