#!/bin/bash

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

