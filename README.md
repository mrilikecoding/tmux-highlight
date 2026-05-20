# tmux-highlight

Color-tag multiple tmux panes with independent per-pane border colors.

tmux's built-in `mark` is a single global pointer used for pair operations
like `swap-pane` and `join-pane` — you can only mark one pane at a time.
This plugin adds an independent "highlight" concept: tag any number of
panes with any number of colors, displayed as the pane border color.

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'YOUR-GH-USER/tmux-highlight'
```

`prefix + I` to fetch and source.

Or source directly:

```tmux
run-shell '/path/to/tmux-highlight/highlight.tmux'
```

## Use

- `prefix + H` opens a color picker. Press the first letter of a color
  (`g`/`c`/`y`/`m`/`r`/`b`/`w`) or `x` to clear.
- From the shell or a script:
  ```sh
  tmux set -p @highlight green     # tag the current pane
  tmux set -p -u @highlight        # clear the tag
  ```

Active and inactive panes share the same highlight color when tagged.
The active pane is still identifiable by cursor and `#P`.

## Configure

All options are read at plugin load — change them before the `run` line
that loads TPM (or reload the config after changing).

| Option | Default | Description |
|---|---|---|
| `@highlight-key` | `H` | Prefix key that opens the color menu. |
| `@highlight-colors` | `green cyan yellow magenta red blue white` | Space-separated palette. Each color's first letter becomes its menu shortcut. |
| `@highlight-borders` | `on` | When `on`, the plugin sets `pane-border-style` to color borders by `@highlight`. Set to `off` to leave borders alone (e.g. if you signal highlights via `pane-border-status` instead). |
| `@highlight-inactive-fg` | `colour240` | Border color for untagged inactive panes (ignored when `@highlight-borders` is `off`). |
| `@highlight-active-fg` | `colour250` | Border color for untagged active panes (ignored when `@highlight-borders` is `off`). |

Example:

```tmux
set -g @highlight-colors        'green cyan yellow orange red'
set -g @highlight-inactive-fg   '#3d2b1f'
set -g @highlight-active-fg     '#e09040'
```

Colors can be tmux names (`green`), `colourN` indices, or `#rrggbb` hex.

## Optional: right-click submenu

To add a "Highlight..." item to tmux's right-click pane menu, paste this
into `.tmux.conf` after the plugin loads. It overrides the default
`MouseDown3Pane` binding with a slimmed-down menu plus the highlight
submenu:

```tmux
bind-key -T root MouseDown3Pane if-shell -F -t = "#{||:#{mouse_any_flag},#{&&:#{pane_in_mode},#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}}}" "select-pane -t = ; send-keys -M" "display-menu -T '#[align=centre]#{pane_index} (#{pane_id})' -t = -x M -y M \
  'Horizontal Split' h 'split-window -h' \
  'Vertical Split'   v 'split-window -v' \
  '' \
  'Highlight...'     H \"display-menu -T 'Highlight' -x M -y M \
    Green   g 'set -p @highlight green' \
    Cyan    c 'set -p @highlight cyan' \
    Yellow  y 'set -p @highlight yellow' \
    Magenta m 'set -p @highlight magenta' \
    Red     r 'set -p @highlight red' \
    Blue    b 'set -p @highlight blue' \
    White   w 'set -p @highlight white' \
    '' \
    Clear   x 'set -p -u @highlight'\" \
  '' \
  '#{?#{>:#{window_panes},1},,-}Swap Up'   u 'swap-pane -U' \
  '#{?#{>:#{window_panes},1},,-}Swap Down' d 'swap-pane -D' \
  '' \
  'Kill'    X 'kill-pane' \
  '#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}' z 'resize-pane -Z'"
```

This drops the contextual copy-mode/hyperlink items from the default
menu. To keep those, copy the full default from
`tmux list-keys -T root | grep MouseDown3Pane` and splice the
`Highlight...` item in.

## Why not use `select-pane -P`?

`select-pane -P bg=...` tints the pane's blank cells, which TUI apps
(vim, less, fzf) cover with their own background. Border colors are
unaffected by what's drawn inside the pane.

## License

MIT.
