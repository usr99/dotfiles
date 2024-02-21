#!/bin/bash

BAT=/sys/class/power_supply/BAT0

# Helper to get battery info
get_info() {
	cat $BAT/$1
}

# Get battery icon
get_icon() {
	STATUS="$(get_info status)"
	if [[ $STATUS == "Discharging" ]]; then
		VALUE="$(get_info capacity)"
		if [ $VALUE -gt 90 ]; then
			echo "󰁹"
		elif [ $VALUE -gt 70 ]; then
			echo "󰂂"
		elif [ $VALUE -gt 40 ]; then
			echo "󰁿"
		elif [ $VALUE -gt 20 ]; then
			echo "󰁼"
		else
			echo "󰂎"
		fi
	else
		echo "󰂄"
	fi
}

while true; do
	if [[ "$1" == "--perc" ]]; then
		get_info capacity
	elif [[ "$1" == "--icon" ]]; then
		get_icon
	fi
	sleep 1
done
