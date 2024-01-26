#!/bin/bash

mode=$(eww get MONITOR_MODE)

if [[ "$mode" == "single" ]]; then
	new="double"
else
	new="single"
fi

sed "/MONITOR_MODE/s/$mode/$new/" -i eww.yuck
eww update "MONITOR_MODE=$new"
ln -sf $new"_monitor.conf" ../hypr/monitors.conf

