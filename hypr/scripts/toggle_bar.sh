#!/bin/bash

if [[ `eww active-windows | grep bar` == "" ]]; then
	eww open bar-monitor0 && eww open bar-monitor1
else
	eww close-all 
fi

