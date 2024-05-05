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

function read_with_default {
	text=$1
	defvalue=$2
	pattern=$3

	while true; do
		echo -en $text " "
		read input

		if [[ "$input" != "" ]]; then
			if [[ "$input" =~ $pattern ]]; then
				retval=$input
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
	index=0

	# Indexing starts at 0 and the first argument is not an entry 
	# so the maximum entry index is the number of args - 2
	max=$(expr ${#args[@]} - 2)

	echo $BLUE$text ":"$WHITE
	for i in "${args[@]:1}"; do
		echo "[$YELLOW$index$WHITE]" $i
		index=$(expr $index + 1)
	done

	while true; do
		echo -n "Number : "
		read num

		if [[ "$num" =~ "^[0-$max]$" ]]; then
			retval=${args[$(expr $num + 2)]}
			return 
		else
			echo $RED"Your input must be a number in the following range [0-$max]"$WHITE
		fi
	done
}

