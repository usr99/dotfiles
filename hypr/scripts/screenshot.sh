#!/bin/bash

case $1 in
	"--full")
		grim - | wl-copy
	;;
	"--area")
		grim -g "$(slurp -d)" - | wl-copy
	;;
	"--save")
		wl-paste > ~/Pictures/screen.png
	;;
esac
