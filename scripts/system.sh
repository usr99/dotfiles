#!/bin/zsh

dirname=$(dirname "$0")
source "$dirname/utils.sh"

TMPFILE=".tmp.wiguewihfg7sdrtg6d7s8tgw8ej"

EFI=
SWAP=
HOME=
ROOTFS=

function __pacstrap {
	read_with_entries "CPU:" "amd" "intel"
	cpu=$retval
	read_with_entries "install os-prober ? (detect other systems)" "yes" "no"
	osprober=$retval
	read_with_entries "install nvidia drivers ? (mandatory with Hyprland)" "yes" "no"
	nvidia=$retval

	packages=( \
		"base" "linux" "linux-firmware" "linux-headers" \
		"grub" "efibootmgr" \
		"iwd" "networkmanager" "dhcpcd" "openssh" \
		"vim" "git" "sudo" \
		"man-pages" "man-db" "texinfo" )

	if [[ "$cpu" == "amd" ]]; then
		packages+=("amd-ucode")
	else
		packages+=("intel-ucode")
	fi

	if [[ "$osprober" == "yes" ]]; then
		packages+=("os-prober")
		export ENABLE_OS_PROBER=1
	fi

	if [[ "$nvidia" == "yes" ]]; then
		# packages+=("nvidia-dkms")
		export ENABLE_NVIDIA_DRIVERS=1
	fi

	pacstrap -K /mnt ${packages[@]}
}

function select_disk {
	partitiontype=$1
	disks=($(lsblk -r -o NAME,PARTTYPENAME | grep '[A-Za-z0-9]$' | tail -n +2 | sed 's/\([a-zA-Z0-9]*\) \(.*\)/\1 \2/g'))

	i=1
	entries=()
	while [ $i -lt ${#disks[@]} ]; do
		name=${disks[$i]}
		type=${disks[$(expr $i + 1)]}

		if [[ "$type" == "$partitiontype" ]]; then
			entries+=("$name $GREEN($type)$WHITE")
		else
			entries+=("$name $YELLOW($type)$WHITE")
		fi

		i=$(expr $i + 2)
	done

	read_with_entries "Choose a $GREEN$partitiontype$BLUE partition:" ${entries[@]}
	retval="/dev/"$(echo $retval | grep -o '^[^ ]*')
}

function diy_partitioning {
	echo $YELLOW"[WARNING]"$WHITE "You must format your partitions yourself !"
	echo $YELLOW"[WARNING]"$WHITE "Go back if you didn't."
	wait_for_input

	select_disk "EFI\x20System"
	EFI=$retval
	select_disk "Linux swap"
	SWAP=$retval
	select_disk "Linux home"
	HOME=$retval
	select_disk "Linux filesystem"
	ROOTFS=$retval
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
	disks=($(lsblk -dp | grep -o '^/dev[^ ]*' | tr '\n' ' '))
	read_with_entries "Choose a disk" ${disks[@]}
	disk=$retval

	read_with_entries "Choose a tabletype" "MBR" "GPT" 
	tabletype=$retval

	# efi_system=$(lsblk -ro NAME,PARTTYPENAME | grep 'EFI\x20System' | grep -o '^[^ ]*') 
	efi_system=$(lsblk -o NAME,PARTTYPENAME | grep 'EFI System' | sed 's/^..\([a-z0-9]*\)\s*EFI System/\1/')
	if [[ "$efi_system" != "" ]]; then
		read_with_entries "$efi_system contains a EFI system partition, would you like to use it ?" "yes" "no"
		if [[ "$retval" == "no" ]]; then
			read_with_default "Size of $GREEN""EFI$BLUE partition [512M] ?" "512M" '^[0-9]*(K|M|G|T|P)$'
			sizeof_efi=$retval
		fi
	else
		read_with_default "Size of $GREEN""EFI$BLUE partition [512M] ?" "512M" '^[0-9]*(K|M|G|T|P)$'
		sizeof_efi=$retval
	fi

	read_with_default "Size of $GREEN""SWAP$BLUE partition [4G] ?" "4G" '^[0-9]*(K|M|G|T|P)$'
	sizeof_swap=$retval
	read_with_default "Size of $GREEN""HOME$BLUE partition [30G] ?" "30G" '^[0-9]*(K|M|G|T|P)$'
	sizeof_home=$retval

	if [[ "$tabletype" == "MBR" ]]; then
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

	print_header "Formatting partitions"
	mkfs.fat -F 32 $EFI
	mkswap $SWAP
	mkfs.ext4 -F $HOME # -F to overwrite any previous ext4
	mkfs.ext4 -F $ROOTFS

	print_header "Mountpoints"
	mount $ROOTFS /mnt
	mount --mkdir $EFI /mnt/boot
	mount --mkdir $HOME /mnt/home
	swapon $SWAP
}

function partitioning {
	read_with_entries "Do you want this script to format your disk ?" "yes" "no"
	if [[ "$retval" == "no" ]]; then
		diy_partitioning
	else
		default_partitioning
	fi
}

function uncomment {
	filename=$1
	pattern=$2

	sed "/$pattern/s/^#//g" -i $filename
}

function __arch-chroot {
	print_header "Time" 2
	read_with_default "Set your timezone ? [Europe/Paris]" "Europe/Paris"
	timezone=$retval
	ln -sf /mnt/usr/share/zoneinfo/$timezone /mnt/etc/localtime
	timedatectl set-timezone $timezone

	print_header "Locale" 2
	read_with_entries "Choose your language" "fr_FR" "en_US"
	echo LANG=$retval.UTF-8 > /mnt/etc/locale.conf
	read_with_entries "Choose your keyboard layout" "fr" "us"
	echo KEYMAP=$retval > /mnt/etc/vconsole.conf
	echo -n "Set your hostname ? "
	cat > /mnt/etc/hostname
	uncomment /mnt/etc/locale.gen "en_US.UTF-8"
	uncomment /mnt/etc/locale.gen "fr_FR.UTF-8"

	print_header "Create your main user" 2
	read_input "username"
	export USERADD_NAME=$retval
	read_secret "password"
	export USERADD_PASSWD=$retval

	print_header "root" 2
	read_secret "root password"
	export ROOT_PASSWD=$retval

	print_header "Configuration" 2
	wait_for_input
	print_header "Enable pacman parallel downloads" 3
	uncomment /mnt/etc/pacman.conf "ParallelDownloads"
	print_header "Sudoers" 3
	echo "sudo ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/rules.conf
	cat > /mnt/etc/sudoers.d/settings.conf << EOF
echo "Defaults insults" >> /mnt/etc/sudoers
echo "Defaults timestamp_timeout=15" >> /mnt/etc/sudoers
EOF

	if [[ $ENABLE_OS_PROBER -eq 1 ]] ; then
		print_header "Enable os-prober" 2
		uncomment /mnt/etc/default/grub "GRUB_DISABLE_OS_PROBER=false"
	fi
	if [[ $ENABLE_NVIDIA_DRIVERS -eq 1 ]] ; then
		print_header "Add nvidia modules" 2
		sed '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ nvidia_drm.modeset=1"/g' -i /mnt/etc/default/grub
		sed '/MODULES=/s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' -i /mnt/etc/mkinitcpio.conf
		echo "options nvidia-drm modeset=1" > /mnt/etc/modprobe.d/nvidia.conf
		echo see $BLUE"https://wiki.hyprland.org/Nvidia/"$WHITE for more info
	fi

	cat $dirname/chroot.sh | arch-chroot /mnt
}
#
# print_header "Verify boot mode"
# if [[ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]]; then
# 	echo "You must boot in x64 UEFI for this installation"
# 	return
# fi
#
# print_header "Enable wpa_supplicant"
# wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlan0
#
# print_header "Partitioning"
# partitioning
#
# print_header "Install essential packages"
# __pacstrap
# genfstab -U /mnt >> /mnt/etc/fstab
#
__arch-chroot

# umount -R /mnt
# warn for grub
# warn for dns issues 
# run install desktop next time :)
# reboot

