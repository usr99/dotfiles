#!/bin/zsh

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
	read -n 1
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

function read_input {
	text=$1
	rdargs=$2

	if [[ "$text" != "" ]]; then
		echo $BLUE$text$WHITE
	fi
	echo -n $BLUE"> "$WHITE
	read $rdargs retval
}

function read_secret {
	read_input $1 '-s'
	echo
}

function read_with_default {
	text=$1
	defvalue=$2
	pattern=$3

	while true; do
		read_input $text

		if [[ "$retval" != "" ]]; then
			if [[ "$retval" =~ $pattern ]]; then
				return 
			fi
			echo -e $RED"Your input does not match this pattern: $pattern"$WHITE
		else
			retval=$defvalue
			return
		fi
	done
}

function read_with_entries {
	args=($@)
	text=${args[1]}
	index=1

	# The first argument is not an entry 
	# so the maximum entry index is the number of args - 1
	max=$(expr ${#args[@]} - 1)

	echo $BLUE$text ":"$WHITE
	for i in "${args[@]:1}"; do
		echo "[$YELLOW$index$WHITE]" $i
		index=$(expr $index + 1)
	done

	while true; do
		read_input

		if [[ "$retval" =~ "^[1-$max]$" ]]; then
			retval=${args[$(expr $retval + 1)]}
			return 
		else
			echo $RED"Your input must be a number in the following range [1-$max]"$WHITE
		fi
	done
}

