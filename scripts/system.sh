#!/bin/bash

dirname=$(dirname "$0")
source "$dirname/utils.sh"

TMPFILE=".tmp.wiguewihfg7sdrtg6d7s8tgw8ej"

EFI=
SWAP=
HOME=
ROOTFS=

function __pacstrap {
	print_header "Install essential packages"
	wait_for_input

	read_with_default "CPU ? [AMD/intel]" cpu "amd" "^(amd|intel)$" 
	read_with_default "install os-prober (detect other systems) ? [y/N]" osprober "N" "^(y|n)$"
	read_with_default "install nvidia drivers ? (mandatory with Hyprland) [y/N]" nvidia "N" "^(y|n)$"

	packages=( \
		"base" "linux" "linux-firmware" "linux-headers" \
		"grub" "efibootmgr" \
		"iwd" "networkmanager" "dhcpcd" "openssh" \
		"vim" "man-pages" "man-db" "texinfo" )

	if [[ "$cpu" == "amd" ]]; then
		packages+=("amd-ucode")
	else
		packages+=("intel-ucode")
	fi

	if [[ "$osprober" == "y" ]]; then
		packages+=("os-prober")
	fi

	if [[ "$nvidia" == "y" ]]; then
		packages+=("nvidia-dkms")
	fi

	pacstrap -K /mnt ${packages[@]}
}

function diy_partitioning {
	echo $YELLOW"[WARNING]"$WHITE "You must format your partitions yourself !"
	echo $YELLOW"[WARNING]"$WHITE "Go back if you didn't."
	wait_for_input

	echo -en "Path to" $GREEN"EFI$WHITE partition ? "
	read EFI 
	echo -en "Path to" $GREEN"SWAP$WHITE partition ? "
	read SWAP
	echo -en "Path to" $GREEN"HOME$WHITE partition ? "
	read HOME
	echo -en "Path to" $GREEN"ROOT$WHITE partition ? "
	read ROOTFS
}

function read_with_default {
	text=$1
	local -n value=$2
	defvalue=$3
	pattern=$4

	while true; do
		echo -en $text " "
		read input

		if [[ "$input" != "" ]]; then
			if [[ "$input" =~ $pattern ]]; then
				value=$input
				return 
			fi
			echo -e $RED"Your input does not match this pattern: $pattern"$WHITE
		else
			value=$defvalue
			return
		fi
	done
}

function set_partition_type {
	type=$1
	id=$2

	echo t >> $TMPFILE
	echo $id  >> $TMPFILE
	echo $type >> $TMPFILE
}

function create_partition {
	size=$1

	echo n >> $TMPFILE
	echo   >> $TMPFILE
	echo   >> $TMPFILE

	if [[ "$size" != "" ]]; then
		echo -n "+" >> $TMPFILE
	fi
	echo $size >> $TMPFILE
}

function default_partitioning {
	disk="/dev/nvme0n1"
	tabletype="GPT"
	sizeof_efi="512M"
	sizeof_swap="4G"
	sizeof_home="30G"
	# read -p "Target disk ? " disk
	# read_with_default "Type of partition table [MBR/gpt] ?" tabletype "MBR" '^(mbr|MBR|gpt|GPT)$'
	# read_with_default "Size of $GREEN""EFI$WHITE partition [512M] ?" sizeof_efi "512M" '^[0-9]*(K|M|G|T|P)$'
	# read_with_default "Size of $GREEN""SWAP$WHITE partition [4G] ?" sizeof_swap "4G" '^[0-9]*(K|M|G|T|P)$'
	# read_with_default "Size of $GREEN""HOME$WHITE partition [30G] ?" sizeof_home "30G" '^[0-9]*(K|M|G|T|P)$'

	if [[ "${tabletype^^}" = "MBR" ]]; then
		tabletype="o"
	else
		tabletype="g"
	fi

	echo $tabletype > $TMPFILE # init partition
	create_partition $sizeof_efi
	create_partition $sizeof_swap
	create_partition $sizeof_home
	create_partition # root partition 
	set_partition_type "uefi" 1
	set_partition_type "swap" 2
	set_partition_type "home" 3
	echo p >> $TMPFILE # print partition table
	echo w >> $TMPFILE # save to disk
	cat $TMPFILE | fdisk $disk
	rm $TMPFILE

	EFI="$disk""p1"
	SWAP="$disk""p2"
	HOME="$disk""p3"
	ROOTFS="$disk""p4"

	print_header "Formatting partitions" 3
	mkfs.fat -F 32 $EFI
	mkswap $SWAP
	mkfs.ext4 $HOME
	mkfs.ext4 $ROOTFS

	print_header "Mountpoints" 3
	mount $ROOTFS /mnt
	mount --mkdir $EFI /mnt/boot
	mount --mkdir $HOME /mnt/home
	swapon $SWAP
}

function partitioning {
	print_header "Partitioning"
	wait_for_input

	# read -p "Do you want this script to format your disk ? [y/N] " yesno
	yesno="y"

	if [[ "$yesno" != "y" ]]; then
		diy_partitioning
	else
		default_partitioning
	fi
}

print_header "Verify boot mode"
if [[ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]]; then
	echo "You must boot in x64 UEFI for this installation"
	return
fi
	# umount -R /mnt

	# warn for grub
	# warn for dns issues 
	# run install desktop next time :)
	# reboot

partitioning efi swap home root

# __pacstrap
genfstab -U /mnt >> /mnt/etc/fstab

print_header "arch-chroot"
wait_for_input
cat $dirname/utils.sh $dirname/chroot.sh | arch-chroot /mnt

