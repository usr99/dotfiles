#!/bin/bash

if [[ `eww active-windows | grep bar` == "" ]]; then
	eww open bar
else
	eww close bar
fi
