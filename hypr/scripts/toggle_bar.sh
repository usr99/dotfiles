#!/bin/bash

if [[ `eww active-windows | grep bar` == "" ]]; then
	eww open bar-monitor0
else
	eww close-all 
fi

