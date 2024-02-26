This file contains instructions to setup a desktop environment on Arch Linux.

# System installation

Follow the ArchLinux installation. Below are some hints to help you.

## Before chroot
### Azerty layout
* `loadkeys fr`
### Partitioning
* fdisk /dev/...
	* uefi 512M
	* swap 1-2G
	* linux filesystem for the rest

## After chroot
### Pacman
* uncomment `ParallelDownloads = 5` in `/etc/pacman.conf`
### Microcode update
* install grub first
* `pacman -S intel-ucode or amd-ucode`
* generate grub config with `grub-mkconfig -o /boot/grub/grub.cfg`
* reboot then check with `journalctl -k --grep=microcode`
### Network Configuration
* `iwd` is the wireless daemon that handles Wifi protocols (`iwctl` is the CLI)
* `dhcpcd` is the daemon for dynamic obtention of an IP address
* `networkmanager` has a cli frontend
* both have to be enabled with `systemctl enable`
* if you encounter name resolution issues, edit `/etc/resolv.conf`

Now you can boot in the system.

# Security stuff

### Create your user
* `useradd -m -G wheel <username>`
* `passwd <username>`
### Sudo
* install `sudo`
* then with `SUDO_EDITOR=vim visudo` add the following:
	* `Defaults timestamp_timeout=15`
	* `Defaults insults`
	* uncomment the part about the `wheel` group at the end
### Root user
* lock the root user with `passwd -l root`
### Firewall
* install `nftables` or `iptables` and `ufw`
* `sudo ufw default deny`
* don't forget `sudo ufw enable`

# Desktop

### Configure date and time
* `timedatectl set-ntp true`
### Configure AUR
* `git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si`
* `yay -Y --gendb && yay -Syu --devel && yay -Syu --devel --save`
### Compositor (Hyprland)
* install `hyprland alacritty gtk3`
* run `Hyprland`
### Audio Configuration
* install `pipewire pipewire-pulse pipewire-audio pipewire-jack wireplumber`
* https://www.youtube.com/watch?v=HxEXMHcwtlI&list=WL&index=9&pp=gAQBiAQB
* add the following to your Hyprland launch script:
	* `exec /usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber`
#### Audio recording
* nothing worked before I installed audio-recorder(AUR), maybe there is something about a dependency
### Bluetooth configuration
* requires `pipewire-audio`
* install `bluez` and `bluez-utils`
* `bluetoothctl` is the CLI, look into its help menu to connect a device
### Fonts
* `JetBrains Noto Meslo FiraMono`
### File manager
* install `thunar`
* I didn't really use it, prefer ls
### Terminal emulator
##### ~/.config/alacritty/alacritty.toml
* install `alacritty`
### Rofi
##### ~/.config/hypr/rofi_launcher.sh
##### ~/.config/hypr/powermenu.sh
##### ~/.config/rofi/*.asi
* install `AUR/rofi-lbonn-wayland-git`
* `SUPER + SPACE` Open app launcher
* `SUPER + ESCAPE` Open powermenu
### Blue light filter
* install `AUR/hyprshade`
* `SUPER + S` Toggle blue light filter
### Hyprpicker
* install `AUR/hyprpicker-git`
* `SUPER + E` Launch hyprpicker
### Swaylock
##### ~/.config/swaylock/lock.sh
* install `AUR/swaylock-effects-git`
* `SUPER + L` Lock screen
### Wallpaper
##### ~/.config/hypr/bythefire.gif
* install `AUR/swww`
### Widgets
##### ~/.config/eww/*
##### ~/.config/hypr/toggle_bar.sh
* install `AUR/eww-git` or compile from sources
* install `brightnessctl gtk-layer-shell`
### XDG
* install `xdg-utils` for xdg-open
* install `feh` for an image viewer
* `xdg-mime default feh.desktop image/*`
### Screenshot
##### ~/.config/hypr/screenshot
* install `grim slurp xdg-user-dirs wl-clipboard`
* init home folder `LC_ALL=C xdg-user-dirs-update --force`

# Dev

### Terminal
##### ~/.zshrc
##### ~/.p10k.zsh
* install `zsh` + `oh-my-zsh` + `powerlevel10k`
	* execute `p10k configure`
		* Classic > Unicode > Dark > no time > Angled > Blurred > Blurred > Two Lines > Disconnected >
			No frame > Sparse > Few icons > Concise > enable Transient Prompt > Verbose > Save  
##### ~/.config/tmux/tmux.conf
* install `tmux`
	* open `tmux` then type `<prefix> + I` to install plugins
	* prefix is `CTRL + X` by default
##### ~/.config/nvim
* install `neovim unzip ripgrep fd` 
* `rustup component add rust-analyzer rustfmt`
### Rust
* install `rustup`

# Keybinds
## Hyprland
##### Applications
* SUPER + Q                 Terminal
* SUPER + A                 Browser
##### Desktop
* SUPER + B                 Toggle eww bar
* SUPER + E                 Enable color picker
* SUPER + L                 Lock screen
* SUPER + S                 Toggle blue light filter
* SUPER + Escape            Open powermenu
* SUPER + Space             Open app launcher
##### Windows
* SUPER + Left              Move focus left
* SUPER + Right             Move focus right 
* SUPER + Down              Move focus down 
* SUPER + Up                Move focus up 
* SUPER + SHIFT + Left      Move window left
* SUPER + SHIFT + Right     Move window right 
* SUPER + SHIFT + Down      Move window down 
* SUPER + SHIFT + Up        Move window up 
* SUPER + F11               Toggle fullscreen
* SUPER + F                 Toggle floating window
* SUPER + C                 Kill active window
##### Screenshot
* SUPER + Print             Screenshot the entire screen
* SUPER + SHIFT + Print     Screenshot an area of the screen
* ALT + Print               Save the last screenshot as ~/Pictures/scren.png 
## tmux
* CTRL + X                  Prefix combination
* PREFIX + {-,|}            Split planes h/v
* PREFIX + Z                Zoom active pane
* PREFIX + C                Create window
* PREFIX + X                Kill pane
* PREFIX + &                Kill window
* CTRL + {h,j,k,l}          Move focus between panes
* ALT + SHIFT + {h,l}       Move focus between windows
## alacritty
* CTRL + {0,-,+}            Edit font size

