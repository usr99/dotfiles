#!/usr/bin/zsh

PACKAGES_COMMON=( \
	base base-devel linux linux-firmware linux-headers \
	grub efibootmgr \
	iwd networkmanager dhcpcd openssh ufw nftables bluez bluez-utils \
	pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber \
	noise-suppression-for-voice pulseaudio-alsa \
	gtk3 gtk-layer-shell qt5ct libva \
	sudo man-pages man-db texinfo \
	firefox discord feh unzip ripgrep fd pulsemixer \
	alacritty neovim vim git tmux zsh zoxide fzf rustup \
	ttf-jetbrains-mono-nerd ttf-firacode-nerd \
	xdg-utils xdg-user-dirs \
)
PACKAGES_WAYLAND=( \
	hyprland wl-clipboard grim slurp qt5-wayland \
)
PACKAGES_X11=( \
	picom xorg xorg-xinit rofi i3-wm xclip nitrogen \
)

AUR_COMMON=( \
	zsh-theme-powerlevel10k-git \
	breezex-cursor-theme \
)
AUR_WAYLAND=( \
	rofi-lbonn-wayland-git \
	hyprshade hyprpicker-git \
	swaylock-effects-git \
	swww eww-git \
)
AUR_X11=()

# Retrieve CPU model as lowercase
CPU=$(LC_ALL=C lscpu | \
			   grep '^Model name' | \
			   grep -Eo '(AMD|Intel)' | \
			   sed 's/.*/\L&/'
)
PACKAGES_COMMON+=($CPU-ucode)

# Detect NVIDIA GPU to install proprietary drivers
NVIDIA_GPU=0
if lspci | grep 'VGA compatible controller.*NVIDIA' > /dev/null; then
	NVIDIA_GPU=1
	PACKAGES_COMMON+=(nvidia-dkms)
	AUR_COMMON+=(libva-nvidia-driver-git)
fi

if [ $ENABLE_GAMING -eq 1 ]; then
	PACKAGES_COMMON+=(jdk21-openjdk)
	PACKAGES_MULTILIB=(steam lib32-libpulse)
	AUR_COMMON+=( \
		heroic-games-launcher \
		prismlauncher \
	)
fi

if [ $ENABLE_KVM -eq 1 ]; then
	PACKAGES_COMMON+=(qemu-base libvirt virt-manager dnsmasq)
fi

if [ $ENABLE_TORRENT_DL -eq 1 ]; then
	PACKAGES_COMMON+=(transmission-cli)
	AUR_COMMON+=(tremc-git)
fi

