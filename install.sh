#!/bin/bash

case $1 in
	scripts="$(dirname "$0")/scripts"

	"system")
		$scripts/system.sh
	;;
	"desktop")
		$scripts/desktop.sh
	;;
	*)
		echo "Specify one of {system, desktop}"
	;;
esac

