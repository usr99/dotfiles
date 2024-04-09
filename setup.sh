#!/bin/bash

ZSHRC="$(cat << EOF
# Some aliases that I like
alias grep=rg
alias vim=nvim
alias open=xdg-open

# Zoxide configuration
eval "$(zoxide init zsh)"
alias cd=z

# Add cargo install dir to PATH
export PATH=~/.cargo/bin:$PATH

# Make nvim the default editor for git and others
export EDITOR=nvim

EOF
)"

sudo pacman -S \
	nftables ufw \
	binutils make gcc pkg-config fakeroot flex bison \
	hyprland gtk3 gtk-layer-shell qt5-wayland qt5ct libva \
	pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber \
	bluez bluez-utils \
	thunar alacritty firefox discord pulsemixer \
	xdg-utils xdg-user-dirs wl-clipboard grim slurp feh \
	zsh tmux neovim unzip ripgred fd \
	rustup \
	ttf-jetbrains-mono-nerd ttf-firacode-nerd \
	zoxide fzf

# Install yay to help with AUR installations 
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -Y --gendb && yay -Syu --devel && yay -Syu --devel --save
rm -rf ./yay

yay -S \
	rofi-lbonn-wayland-git \
	hyprshade hyprpicker-git \
	swaylock-effects-git \
	swww \
	eww-git \
	noise-suppression-for-voice \
	libva-nvidia-driver-git \
	zsh-theme-powerlevel10k-git

sudo systemctl enable --now iwd # Wireless daemon
sudo systemctl enable --now dhcpcd
sudo systemctl enable --now bluetooth

# Default firewall settings
sudo ufw enable
sudo ufw default deny

# Configure SSH 
cd ~/.ssh
ssh-keygen -t rsa # RSA keys generation
touch authorized_keys # File where are stored public keys to enable key-based authentication 
# Add configuration for my other computers 
echo "Host $SSH_HOSTNAME" > config
echo "    HostName $SSH_IP" >> config
echo "    User $SSH_USER" >> config
echo "    RequestTTY yes" >> config
echo "    RemoteCommand /usr/bin/zsh -l -c 'tmux'" >> config
cd - 

# Manually install the Icomoon Feather font
# it's only used in some rofi menus 
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/adi1090x/rofi/raw/master/fonts/Icomoon-Feather.ttf
cd -

# Configure git
# todo: add more options
git config --global user.mail $GIT_MAIL
git config --global user.name $GIT_USERNAME

# Install the TMUX plugin manager
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install OhMyZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e "$ZSHRC" >> ~/.zshrc

# Create user directories
# Downloads, Pictures, etc.
LC_ALL=C xdg-user-dirs-update

# Rust toolchain
rustup default stable
rustup component add rust-analyzer

