hwclock --systohc
locale-gen

groupadd sudo
useradd --create-home --groups sudo --shell /usr/bin/zsh $USERADD_NAME
echo "$USERADD_NAME:$USERADD_PASSWD" | chpasswd

echo "root:$ROOT_PASSWD" | chpasswd
passwd -l root

su $USERADD_NAME -c "git clone https://github.com/usr99/dotfiles /home/$USERADD_NAME/.config"
touch /home/$USERADD_NAME/.zshrc

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

if [[ $ENABLE_NVIDIA_DRIVERS -eq 1 ]] ; then
	mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
fi

