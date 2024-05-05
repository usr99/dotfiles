#!/bin/bash

if [ ! -n "$TMUX" ]; then
	echo "It is mandatory to run this script inside a TMUX session"
	exit
fi

sourcedir=$(dirname "$0")

case $1 in
	"system")
		$sourcedir/scripts/system.sh
	;;
	"desktop")
		$sourcedir/scripts/desktop.sh
	;;
	*)
		echo "Specify one of {system, desktop}"
	;;
esac

