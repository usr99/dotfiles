#!/bin/bash

MAX=24000

## Get Brightness
get_blight() {
	while true; do
		echo $(( $(brightnessctl get) * 100 / $MAX ))
		sleep 1
	done
}

## Set Brightness
set_blight() {
  brightnessctl set $1%
}



if [[ "$1" == "--get" ]]; then
	get_blight
elif [[ "$1" == "--set" ]]; then
	set_blight "$2"
fi
