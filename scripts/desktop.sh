#!/bin/zsh

source "$(dirname "$0")/utils.sh"

SSH_DIR="$HOME/.ssh"
ZSHRC="$HOME/.zshrc"

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
		zsh neovim unzip ripgrep fd \
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

	
	print_header "Wifi configuration" 2
	read_input "SSID"
	ssid=$retval
	read_secret "Password"
	psk=$retval

	nmcli connection add type wifi con-name $ssid ifname wlan0 ssid $ssid 
	nmcli c modify $ssid wifi-sec.key-mgmt wpa-psk
	nmcli c modify $ssid wifi-sec.psk $psk
	nmcli c up $ssid

	print_header "Configure SSH" 2
	print_header "Generate RSA key pair" 3
	ssh-keygen -t rsa
	print_header "Create SSH authorized_keys file" 3
	touch $SSH_DIR/authorized_keys
	sshconfig
}

function sshconfig {
	read_with_entries "Would you like to add a SSH host ?" "yes" "no"
	if [[ "$retval" != "yes" ]]; then
		return 
	fi

	read_input "Hostname"
	host=$retval
	read_input "IP Address"
	addr=$retval
	read_input "Username"
	user=$retval

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

function dev {
	print_header "Dev environment setup"
	wait_for_input

	print_header "GIT configuration" 2
	read_input "Email Address"
	mail=$retval
	read_input "Username"
	username=$retval

	git config --global user.email $mail
	git config --global user.name $username

	print_header "Rust toolchain" 2
	rustup default stable
	rustup component add rust-analyzer
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

networking
pacman
paru
terminal
dev
misc

