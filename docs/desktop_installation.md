* create user
    * useradd -m -G wheel <username>
    * passwd <username>
* pacman -S sudo
* SUDO_EDITOR=vim visudo
	* `Defaults timestamp_timeout=15`
	* `Defaults insults`
	* uncomment the part about the `wheel` group at the end
* lock root
    * passwd -l root
* reboot and log as <username>

* pacman -S
    * nftables ufw
    * binutils make gcc pkg-config fakeroot flex bison
    * hyprland gtk3 gtk-layer-shell qt5-wayland qt5ct libva
    * pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber
    * bluez bluez-utils
    * thunar alacritty firefox pulsemixer
    * xdg-utils xdg-user-dirs wl-clipboard grim slurp feh
    * zsh tmux neovim unzip ripgred fd
    * rustup
    * ttf-jetbrains-mono-nerd ttf-firacode-nerd

* install yay
    * `git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si`
    * `yay -Y --gendb && yay -Syu --devel && yay -Syu --devel --save`
    * rm -rf yay
* yay -S
    * rofi-lbonn-wayland-git
    * hyprshade hyprpicker-git hyprsome-git
    * swaylock-effects-git
    * swww
    * eww-git
    * discord_arch_electron
    * noise-suppression-for-voice
    * libva-nvidia-driver-git
    * zsh-theme-powerlevel10k-git

# network
* run `sudo systemctl start/enable iwd/dhcpcd/bluetooth`
* run `sudo ufw enable && sudo ufw default deny`
* edit /etc/resolv.conf is you encounter DNS issues
* there are 2 important CLIs:
    * nmcli for wifi 
    * bluetoothctl for bluetooth

# XDG
* LC_ALL=C xdg-user-dirs-update

# rustup
* rustup default stable
* rustup component add rust-analyzer

# .zshrc
* sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
* echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
* echo alias grep=rg >> ~/.zshrc
* echo alias vim=nvim >> ~/.zshrc
* echo alias open=xdg-open >> ~/.zshrc
* echo 'export PATH=~/.cargo/bin:$PATH' >> ~/.zshrc
```bash
hypr() {
    cd ~

    # Audio stuff
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
```
* source ~/.zshrc
* p10k configure
    * Classic > Unicode > Dark > no time > Angled > Blurred > Blurred > Two Lines > Disconnected >
        No frame > Sparse > Few icons > Concise > enable Transient Prompt > Verbose > Save  

# tmux
* mkdir -p ~/.tmux/plugins
* git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
* run tmux and press PREFIX + I

# git
* git config --global user.mail <yourmail>
* git config --global user.name <yourname>

# ssh
* ssh-keygen -t rsa
* copy keys to ~/.ssh/authorized_keys for autologin
* here is an example of a host config that runs tmux on startup
```
# ~/.ssh/config
Host arch
    HostName <ip>
    User <username>
    RequestTTY yes
    RemoteCommand /usr/bin/zsh -l -c "tmux"
```

* reboot and run hypr 

