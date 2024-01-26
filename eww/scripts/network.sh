#!/bin/bash

# Helper to get the SSID of the current wifi connection (if any)
get_connection() {
	nmcli -g NAME connection show --active | grep -v lo
}

# Toggle state
toggle() {
	if [ -z "$(get_connection)" ]; then
		nmcli radio wifi on
	else
		nmcli radio wifi off
	fi
}

# Get icon
get_icon() {
	while true; do
		if [ -z "$(get_connection)" ]; then
			echo "󰣽"
		else
			echo "󰣺"
		fi
		sleep 5
	done
}

# Get status
get_status() {
	while true; do
		if [ -z get_connection ]; then
			echo "󰣽 Offline"
		else
			echo "󰣺  $(get_connection)"
		fi
		sleep 5
	done
}