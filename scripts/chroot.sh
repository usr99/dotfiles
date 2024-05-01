#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

sed -e 's/\#en_US.UTF-8/en_US.UTF-8/' -i /etc/locale.gen
sed -e 's/\#fr_FR.UTF-8/fr_FR.UTF-8/' -i /etc/locale.gen
locale-gen

echo LANG=fr_FR.UTF-8 > /etc/locale.conf
echo KEYMAP=us > /etc/vconsole.conf
echo archwin > /etc/hostname

	# passwd
	# useradd -m -G wheel mamartin
	# passwd mamartin
	
	# locale
	# grub
	# create_user


