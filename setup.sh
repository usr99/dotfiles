#!/bin/bash

ZSHRC="$(cat << EOF
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
alias grep=rg
alias vim=nvim
alias open=xdg-open
export PATH=~/.cargo/bin:$PATH

hypr() {
    cd ~

    exec /usr/bin/pipewire & # Audio server
    exec /usr/bin/wireplumber & # Session manager
    exec /usr/bin/pipewire-pulse & # PulseAudio interface

    exec Hyprland
}

switch_monitor_mode() {
	if [[ `eww get MONITOR_MODE` == "single" ]]; then
		eww update MONITOR_MODE=double
		ln -sf ~/.config/hypr/double_monitor.conf ~/.config/hypr/monitors.conf
	else
		eww update MONITOR_MODE=single
		ln -sf ~/.config/hypr/single_monitor.conf ~/.config/hypr/monitors.conf
	fi
}
EOF
)"

sudo pacman -S \
	nftables ufw \
	binutils make gcc pkg-config fakeroot flex bison \
	hyprland gtk3 gtk-layer-shell qt5-wayland qt5ct libva \
	pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber \
	bluez bluez-utils \
	thunar alacritty firefox pulsemixer \
	xdg-utils xdg-user-dirs wl-clipboard grim slurp feh \
	zsh tmux neovim unzip ripgred fd \
	rustup \
	ttf-jetbrains-mono-nerd ttf-firacode-nerd

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -Y --gendb && yay -Syu --devel && yay -Syu --devel --save
rm -rf ./yay

yay -S \
	rofi-lbonn-wayland-git \
	hyprshade hyprpicker-git hyprsome-git \
	swaylock-effects-git \
	swww \
	eww-git \
	discord_arch_electron \
	noise-suppression-for-voice \
	libva-nvidia-driver-git \
	zsh-theme-powerlevel10k-git

enable_service(name) {
	sudo systemctl start name
	sudo systemctl enable name
}

enable_service(iwd)
enable_service(dhcpcd)
enable_service(bluetooth)
sudo ufw enable
sudo ufw default deny

cd ~/.ssh
ssh-keygen -t rsa
touch authorized_keys
echo "Host $SSH_HOSTNAME" > config
echo "    HostName $SSH_IP" >> config
echo "    User $SSH_USER" >> config
echo "    RequestTTY yes" >> config
echo "    RemoteCommand /usr/bin/zsh -l -c 'tmux'" >> config
cd - 

git config --global user.mail $GIT_MAIL
git config --global user.name $GIT_USERNAME

mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e "$ZSHRC" >> ~/.zshrc

LC_ALL=C xdg-user-dirs-update

rustup default stable
rustup component add rust-analyzer

