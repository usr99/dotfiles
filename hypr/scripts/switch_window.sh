#!/bin/bash

current=$(hyprctl activewindow | awk '{ if ($1 == "workspace:") print $2 }')

workspaces=($(hyprctl workspaces | awk '{ if ($1 == "workspace") print $3 }'))
for w in ${workspaces[@]}
do
	if [[ "$w" != "$current" ]]; then
		hyprctl dispatch workspace $w
	fi
done

