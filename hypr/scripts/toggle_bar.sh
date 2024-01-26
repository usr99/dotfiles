#!/bin/bash

if eww active-windows | grep bar ; then
	eww close-all 
else
	eww open bar-monitor0
	if [[ `eww get MONITOR_MODE` == "double" ]]; then
		eww open bar-monitor1
	fi
fi

