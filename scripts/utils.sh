#!/bin/bash

RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'
WHITE='\033[0;0m'

function printc {
	str=$1
	color=$2

	echo -en $color
	echo -n  $str
	echo -e  $WHITE
}

function wait_for_input {
	printc "Press [ENTER] to continue" $YELLOW
	read -n1
}

function print_header {
	text=$1
	case $2 in 
		1)
			color=$BLUE
		;;
		2)
			color=$PURPLE
		;;
		3)
			color=$YELLOW
		;;
		*)
			color=$BLUE
		;;
	esac
	
	printc "$text" $color
}

