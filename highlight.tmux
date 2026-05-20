#!/usr/bin/env bash
#
# tmux-highlight — color-tag multiple panes with per-pane border colors.
#
# Sets a per-pane user option `@highlight` to a tmux color name, then
# expands that into `pane-border-style` so several panes can be visually
# distinguished at once. Unlike tmux's built-in `mark`, which is a
# single global pointer for pair operations, highlights are independent
# and many panes can be highlighted concurrently.

get_tmux_option() {
    local option="$1" default_value="$2" option_value
    option_value=$(tmux show-option -gqv "$option")
    [ -z "$option_value" ] && printf '%s\n' "$default_value" || printf '%s\n' "$option_value"
}

KEY=$(get_tmux_option "@highlight-key" "H")
BORDERS=$(get_tmux_option "@highlight-borders" "on")
INACTIVE_FG=$(get_tmux_option "@highlight-inactive-fg" "colour240")
ACTIVE_FG=$(get_tmux_option "@highlight-active-fg" "colour250")
COLORS=$(get_tmux_option "@highlight-colors" "green cyan yellow magenta red blue white")

if [ "$BORDERS" = "on" ]; then
    tmux set-option -g pane-border-style        "#{?@highlight,fg=#{@highlight},fg=$INACTIVE_FG}"
    tmux set-option -g pane-active-border-style "#{?@highlight,fg=#{@highlight},fg=$ACTIVE_FG}"
fi

menu_args=()
for color in $COLORS; do
    menu_args+=("$color" "${color:0:1}" "set -p @highlight $color")
done
menu_args+=("")
menu_args+=("Clear" "x" "set -p -u @highlight")

tmux bind-key -N "Highlight pane" "$KEY" \
    display-menu -T "#[align=centre]Highlight" -x P -y P "${menu_args[@]}"
