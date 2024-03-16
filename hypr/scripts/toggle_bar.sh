#!/bin/bash

if [[ `eww active-windows | grep bar` == "" ]]; then
	eww open bar-monitor0
	if [[ `eww get MONITOR_MODE` == "double" ]]; then
		eww open bar-monitor1
	fi
else
	eww close-all 
fi

