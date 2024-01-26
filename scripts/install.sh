#!/usr/bin/zsh

dirname=$(dirname "$0")
source "$dirname/utils.sh"
source "$dirname/config.sh"
source "$dirname/packages.sh"

WIFI_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"

function uncomment {
	filename=$1
	pattern=$2

	sed "/$pattern/s/^#//g" -i $filename
}

set -e

if [ ! -n "$TMUX" ]; then
	echo "It is mandatory to run this script inside a TMUX session"
	exit
fi

print_header "Verify boot mode"
if [[ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]]; then
	echo "You must boot in x64 UEFI for this installation"
	return
fi

print_header "Enable wpa_supplicant"
wpa_supplicant -B -c $WIFI_CONF -i wlan0

print_header "Partitioning"
if [ ! -z "$DISK" ]; then
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DISK
  g # clear the in memory partition table (g=GPT|o=MBR)
  n # create efi partition


  +512M
  n # create swap partition


  +4G
  n # create home partition


  +30G
  n # create root partition


  # no size specified, will use the remainder of the disk
t # set partition labels
1
uefi
t
2
swap
t
3
home
  w # write the partition table
  q # and we're done
EOF

	EFI="$DISK"p1
	SWAP="$DISK"p2
	HOME="$DISK"p3
	ROOT="$DISK"p4

	mkfs.fat -F 32 $EFI
	mkfs.ext4 -F $HOME
	mkfs.ext4 -F $ROOT
	mkswap $SWAP

	mount $ROOT /mnt
	mount --mkdir $EFI /mnt/boot
	mount --mkdir $HOME /mnt/home
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
cp $WIFI_CONF /mnt$WIFI_CONF

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
fi \n \
 \n \
git clone https://github.com/usr99/dotfiles ~/.config \n \
 \n \
if [ $ENABLE_I3 -eq 1 ] ; then \n \
	echo \"Xcursor.theme: BreezeX-Dark\" > ~/.Xresources \n \
	echo \"Xcursor.size: 32\" >> ~/.Xresources \n \
	ln -sf .config/xinitrc ~/.xinitrc \n \
fi \n \
 \n \
LC_ALL=C xdg-user-dirs-update \n \
 \n \
mkdir -p ~/.local/share \n \
ln -sf ../../.config/fonts ~/.local/share/fonts \n \
ln -sf ../.config/wallpapers ~/Pictures \n \
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

echo $CHROOT_AS_ROOT | arch-chroot /mnt
echo $CHROOT_AS_USER | arch-chroot /mnt su $USER_NAME
echo $ZSHRC >> /mnt/home/$USER_NAME/.zshrc

# Restore a sudo rule that requires password
echo "%sudo ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/rules

