#!/bin/bash

# Get volume
get_vol() {
	while true; do
		pulsemixer --get-volume | cut -f 2 -d ' '
		sleep 1
	done
}

# Set volume
set_vol() {
	pulsemixer --set-volume $1
}

# Toggle volume
toggle_vol() {
	pulsemixer --toggle-mute
}

# Get icon
get_icon() {
	while true; do
		MUTE="$(pulsemixer --get-mute)"
		VOLUME="$(pulsemixer --get-volume | cut -f 1 -d ' ')"
		if [[ "$MUTE" == 1 ]] || [[ "$VOLUME" == 0 ]]; then
			echo "󰖁"
		elif [[ $VOLUME < 31 ]]; then
			echo ""
		else
			echo "󰕾"
		fi
		sleep 2
	done
}

if [[ "$1" == "--get-icon" ]]; then
	get_icon
elif [[ "$1" == "--set-vol" ]]; then
	set_vol $2
elif [[ "$1" == "--get-vol" ]]; then
	get_vol
elif [[ "$1" == "--toggle-vol" ]]; then
	toggle_vol
fi

