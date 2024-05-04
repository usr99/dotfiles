hwclock --systohc
locale-gen

groupadd sudo
useradd -m -G sudo $USERADD_NAME
echo "$USERADD_NAME:$USERADD_PASSWD" | chpasswd

echo "root:$ROOT_PASSWD" | chpasswd
passwd -l root

git clone https://github.com/usr99/dotfiles /home/$USERADD_NAME/.config

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

if [[ $ENABLE_NVIDIA_DRIVERS -eq 1 ]] ; then
	mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
fi

