#!/bin/bash

SSH_DIR="$HOME/.ssh"
ZSHRC="$HOME/.zshrc"
TMPFILE=".tmp.wiguewihfg7sdrtg6d7s8tgw8ej"

EFI=
SWAP=
HOME=
ROOTFS=

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

function pacman {
	print_header "Install packages from Arch repositories"
	wait_for_input

	sudo pacman -Syu \
		nftables ufw \
		bqinutils make gcc pkg-config fakeroot flex bison \
		hyprland gtk3 gtk-layer-shell qt5-wayland qt5ct libva \
		pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber \
		noise-suppression-for-voice \
		bluez bluez-utils \
		thunar alacritty firefox discord pulsemixer \
		xdg-utils xdg-user-dirs wl-clipboard grim slurp feh \
		zsh tmux neovim unzip ripgrep fd \
		rustup \
		ttf-jetbrains-mono-nerd ttf-firacode-nerd \
		zoxide fzf
}

function paru {
	print_header "Install paru and packages from AUR"
	wait_for_input

	git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si
	cd - && rm -r paru 

	paru -S \
		rofi-lbonn-wayland-git \
		hyprshade hyprpicker-git \
		swaylock-effects-git \
		swww \
		eww-git \
		libva-nvidia-driver-git \
		zsh-theme-powerlevel10k-git
}

function networking {
	print_header "Setup networking"
	wait_for_input

	print_header "Enable networking services" 2
	sudo systemctl enable --now iwd # Wireless daemon
	sudo systemctl enable --now dhcpcd
	sudo systemctl enable --now NetworkManager 
	sudo systemctl enable --now bluetooth

	print_header "Enable firewall" 2
	sudo ufw enable
	sudo ufw default deny

	print_header "Configure SSH" 2
	print_header "Generate RSA key pair" 3
	ssh-keygen -t rsa
	print_header "Create SSH authorized_keys file" 3
	touch $SSH_DIR/authorized_keys
	sshconfig
}

function sshconfig {
	echo -en $YELLOW
	read -n 1 -p "Would you like to add a SSH host ? [y/N] " input
	echo -en $WHITE
	echo

	echo $SSH_DIR/config

	if [[ "$input" != "y" ]]; then
		return 
	fi

	read -p "Host ? " host
	read -p "IP ? " addr
	read -p "Username ? " user

	echo "Host $host" > $SSH_DIR/config
	echo "    HostName $addr" >> $SSH_DIR/config
	echo "    User $user" >> $SSH_DIR/config
	echo "    RequestTTY yes" >> $SSH_DIR/config
	echo "    RemoteCommand /usr/bin/zsh -l -c 'tmux'" >> $SSH_DIR/config
}

function terminal {
	print_header "Configure terminal environment"
	wait_for_input

	print_header "Install Tmux Plugin Manager (TPM)" 2
	mkdir -p ~/.tmux/plugins
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	print_header "Install OhMyZSH" 2
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	print_header "Import .zshrc settings" 2
	cat << EOF >> $ZSHRC
# Enable powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Enable zoxide 
eval \"\$(zoxide init zsh)\"

# Add cargo install dir to PATH
export PATH=~/.cargo/bin:\$PATH

# Make nvim the default editor for git and others
export EDITOR=nvim

# Some aliases that I find useful 
alias grep=rg
alias vim=nvim
alias open=xdg-open
alias cd=z
EOF

	print_header "Enable plugins : web-search copyfile  " 2
	sed 's/plugins=(git/& web-search copyfile/' -i $ZSHRC
}

function misc {
	print_header "Miscellaneous ..."
	wait_for_input

	print_header "Manual installation of fonts" 2
	mkdir -p ~/.local/share/fonts
	cp fonts/* ~/.local/share/fonts

	print_header "Setup home directory" 2
	LC_ALL=C xdg-user-dirs-update
}

function dev {
	print_header "Dev environment setup"
	wait_for_input

	print_header "GIT configuration" 2
	read -p "Email Address ? " mail
	read -p "Username ? " username 
	git config --global user.email $mail
	git config --global user.name $username

	print_header "Rust toolchain" 2
	rustup default stable
	rustup component add rust-analyzer
}

# function install_desktop {
# 	# pacman
# 	# paru
# 	# networking
# 	# terminal
# 	# dev
# 	# misc
# }

# function create_user {
#
# }
#
# function locale {
#
# }
#
# function grub {
#
# }

function __arch-chroot {
	arch-chroot /mnt

	ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
	hwclock --systohc
	
	sed -e 's/\#en_US.UTF-8/en_US.UTF-8/' -i /etc/locale.gen
	sed -e 's/\#fr_FR.UTF-8/fr_FR.UTF-8/' -i /etc/locale.gen
	# locale-gen

	echo LANG=fr_FR.UTF-8 > /etc/locale.conf
	echo KEYMAP=us > /etc/vconsole.conf
	echo archwin > /etc/hostname

	# passwd
	# useradd -m -G wheel mamartin
	# passwd mamartin
	
	# locale
	# grub
	# create_user
}

function __pacstrap {
	pacstrap -K /mnt \
		base linux linux-firmware \
		grub efibootmgr \
		vim
		# os-prober \
		# man-pages man-db texinfo \
		# iwd networkmanager dhcpcd openssh \
		# intel-ucode or amd-ucode \
		# nvidia-dkms \
		# linux-headers
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
		echo -en $text "? "
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
	# read_with_default "Type of partition table [MBR/gpt]" tabletype "MBR" '^(mbr|MBR|gpt|GPT)$'
	# read_with_default "Size of $GREEN""EFI$WHITE partition [512M]" sizeof_efi "512M" '^[0-9]*(K|M|G|T|P)$'
	# read_with_default "Size of $GREEN""SWAP$WHITE partition [4G]" sizeof_swap "4G" '^[0-9]*(K|M|G|T|P)$'
	# read_with_default "Size of $GREEN""HOME$WHITE partition [30G]" sizeof_home "30G" '^[0-9]*(K|M|G|T|P)$'

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

	# Format partitions
	mkfs.fat -F 32 $EFI
	mkswap $SWAP
	mkfs.ext4 $HOME
	mkfs.ext4 $ROOTFS
}

function mount_partitions {
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

function install_system {
	if [[ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]]; then
		echo "You must boot in x64 UEFI for this installation"
		return
	fi

	partitioning efi swap home root
	mount_partitions

	__pacstrap
	genfstab -U /mnt >> /mnt/etc/fstab
	__arch-chroot
	# umount -R /mnt

	# warn for grub
	# warn for dns issues 
	# run install desktop next time :)
	# reboot
}

case $1 in
	"system")
		install_system
	;;
	"desktop")
		install_desktop
	;;
	*)
		echo "Specify one of {system, desktop}"
	;;
esac

