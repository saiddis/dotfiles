#!/usr/bin/env bash
hyprctl -q dispatch submap alttab

current=$(hyprctl -j activewindow | jq -r '.address')

address=$(hyprctl -j clients | jq -r --arg current "$current" '
  sort_by(.focusHistoryID)
  | .[]
  | select(.address != $current)
  | "\(.stableId)\t\(.title)\t\(.address)"
' | fzf \
    --color prompt:green,pointer:green,current-bg:black,current-fg:green,gutter:-1,border:bright-black,current-hl:red,hl:red \
    --cycle \
    --sync \
    --bind tab:down,shift-tab:up,start:"$1",double-click:ignore \
    --wrap \
    --delimiter=$'\t' \
    --with-nth=2 \
    --preview "$XDG_CONFIG_HOME/hypr/scripts/alttab/preview.sh {}" \
    --preview-window=down:80% \
    --layout=reverse |
  awk -F"\t" '{print $3}')

if [ -n "$address" ] ; then
	echo "$address" > $XDG_RUNTIME_DIR/hypr/alttab/address
fi

hyprctl -q dispatch submap reset
