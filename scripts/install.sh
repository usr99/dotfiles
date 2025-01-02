#!/usr/bin/zsh

dirname=$(dirname "$0")
source "$dirname/config.sh"
source "$dirname/packages.sh"

function print_header {
	printf "\033[34;1m$1\033[0m\n"
}

function uncomment {
	filename=$1
	pattern=$2

	sed "/$pattern/s/^#//g" -i $filename
}

set -e

if [ ! -n $TMUX ]; then
	echo "It is mandatory to run this script inside a TMUX session"
	exit
fi

print_header "Verify boot mode"
if [ $(cat /sys/firmware/efi/fw_platform_size) -eq 64 ]; then
	echo "You must boot in x64 UEFI for this installation"
	return
fi

if [ ! -z $WPA_CONF ]; then
	print_header "Enable wpa_supplicant"
	wpa_supplicant -B -c $WPA_CONF -i wlan0
fi

print_header "Partitioning"
if [ ! -z $DISK ]; then
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DISK
  g # clear the in memory partition table (g=GPT|o=MBR)
  n # create efi partition


  +512M
  n # create swap partition


  +4G
  n # create root partition


  # no size specified, will use the remainder of the disk
t # set partition labels
1
uefi
t
2
swap
  w # write the partition table
  q # and we're done
EOF

	EFI="$DISK"p1
	SWAP="$DISK"p2
	ROOT="$DISK"p3

	mkfs.fat -F 32 $EFI
	mkfs.ext4 -F $ROOT
	mkswap $SWAP

	mount $ROOT /mnt
	mount --mkdir $EFI /mnt/boot
	swapon $SWAP
fi

print_header "Install essential packages"
pacstrap -K /mnt ${PACKAGES_COMMON[@]}

genfstab -U /mnt >> /mnt/etc/fstab
ln -sf /usr/share/zoneinfo/$TIMEZONE /mnt/etc/localtime
echo LANG=$LANG > /mnt/etc/locale.conf
echo KEYMAP=$KEYMAP > /mnt/etc/vconsole.conf
echo $HOSTNAME > /mnt/etc/hostname

for locale in ${LOCALES[@]}; do
	uncomment /mnt/etc/locale.gen $locale
done
uncomment /mnt/etc/pacman.conf "ParallelDownloads"

if [ ! -z $WPA_CONF ]; then
	cp $WPA_CONF /mnt$WPA_CONF
fi

pushd /mnt/etc/sudoers.d
# the 'NOPASSWD' option is set to make the installation process easier
# it will be removed by the end
echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > rules
echo "Defaults insults" > settings
echo "Defaults timestamp_timeout=15" >> settings
popd

if [ $NVIDIA_GPU -eq 1 ]; then
	sed '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ nvidia_drm.modeset=1"/g' -i /mnt/etc/default/grub
	sed '/MODULES=/s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' -i /mnt/etc/mkinitcpio.conf
	echo "options nvidia-drm modeset=1" > /mnt/etc/modprobe.d/nvidia.conf
fi

# nmcli connection add type wifi con-name $SSID ifname wlan0 ssid $SSID  \n \
# nmcli c modify $SSID wifi-sec.key-mgmt wpa-psk \n \
# nmcli c modify $SSID wifi-sec.psk $PSK \n \
# nmcli c up $SSID \n \
#  \n \

CHROOT_AS_ROOT="\
if [ $ENABLE_HYPRLAND -eq 1 ] ; then \n \
	pacman --noconfirm -S ${PACKAGES_WAYLAND[@]} \n \
fi \n \
 \n \
if [ $ENABLE_I3 -eq 1 ] ; then \n \
	pacman --noconfirm -S ${PACKAGES_X11[@]} \n \
fi \n \
 \n \
if [ $ENABLE_GAMING -eq 1 ] ; then \n \
	echo '[multilib]' >> /etc/pacman.conf \n \
	echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf \n \
	pacman --noconfirm -Syu ${PACKAGES_MULTILIB[@]} \n \
fi \n \
 \n \
hwclock --systohc \n \
locale-gen \n \
 \n \
groupadd sudo \n \
useradd --create-home --groups sudo --shell /usr/bin/zsh $USER_NAME \n \
echo \"$USER_NAME:$PASSWD\" | chpasswd \n \
 \n \
echo \"root:$ROOT_PASSWD\" | chpasswd \n \
passwd -l root \n \
 \n \
systemctl enable iwd \n \
systemctl enable dhcpcd \n \
systemctl enable NetworkManager  \n \
systemctl enable bluetooth \n \
 \n \
ufw enable \n \
ufw default deny \n \
 \n \
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB \n \
grub-mkconfig -o /boot/grub/grub.cfg \n \
 \n \
if [ $NVIDIA_GPU -eq 1 ] ; then \n \
	mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img \n \
fi \n \
 \n \
"

CHROOT_AS_USER="\
cd \$HOME \n \
 \n \
git clone https://github.com/usr99/dotfiles .config \n \
 \n \
rustup default stable \n \
rustup component add rust-analyzer \n \
 \n \
git clone https://aur.archlinux.org/paru.git \n \
pushd paru \n \
makepkg --noconfirm -si \n \
popd \n \
rm -r paru \n \
 \n \
paru --noconfirm -S ${AUR_COMMON[@]} \n \
 \n \
if [ $ENABLE_HYPRLAND -eq 1 ] ; then \n \
	paru --noconfirm -S ${AUR_WAYLAND[@]} \n \
fi \n \
 \n \
if [ $ENABLE_I3 -eq 1 ] ; then \n \
	paru --noconfirm -S ${AUR_X11[@]} \n \
	# Fix bug where the default cursor still shows on most windows
	sed 's/^Inherits.*$/Inherits=BreezeX-Dark/' -i /usr/share/icons/default/index.theme 
fi \n \
 \n \
if [ $ENABLE_I3 -eq 1 ] ; then \n \
	mkdir -p ~/.icons/default \n \
	pushd ~/.icons/default \n \
	echo "[Icon Theme]" > index.theme \n \
	echo "Inherits=BreezeX-Dark" >> index.theme \n \
	echo "Size=32" >> index.theme \n \
	popd \n \
	ln -sf .config/xinitrc ~/.xinitrc \n \
fi \n \
 \n \
LC_ALL=C xdg-user-dirs-update \n \
 \n \
mkdir -p ~/.local/share \n \
ln -sf ../../.config/fonts ~/.local/share/fonts \n \
ln -sf ../.config/wallpapers ~/Pictures \n \
mkdir ~/Pictures/screenshots \n \
 \n \
mkdir -p ~/.tmux/plugins \n \
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \n \
\n \
git config --global user.name $GIT_NAME \n \
git config --global user.email $GIT_EMAIL \n \
\n \
sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed '/exec zsh/s/^/#/')\"
\n \
"

ZSHRC="\
# Enable powerlevel10k theme \n \
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \n \
 \n \
# Enable zoxide  \n \
eval \"\$(zoxide init zsh)\" \n \
 \n \
# Add cargo install dir to PATH \n \
export PATH=~/.cargo/bin:\$PATH \n \
 \n \
# Make nvim the default editor for git and others \n \
export EDITOR=nvim \n \
 \n \
# Some aliases that I find useful  \n \
alias grep=rg \n \
alias vim=nvim \n \
alias open=xdg-open \n \
alias cd=z \n \
"

XORG_TOUCHPAD="\
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection
"

echo $CHROOT_AS_ROOT | arch-chroot /mnt
echo $CHROOT_AS_USER | arch-chroot /mnt su $USER_NAME

echo $ZSHRC >> /mnt/home/$USER_NAME/.zshrc
echo $XORG_TOUCHPAD > /mnt/etc/X11/xorg.conf.d/90-touchpad.conf

# Restore a sudo rule that requires password
echo "%sudo ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/rules

