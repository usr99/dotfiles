#!/usr/bin/zsh

# Select the disk to install the system onto
# comment this line if you want to handle partitioning/formatting/mounting yourself
# the root filesystem is expected to be mounted on /mnt
# the efi FAT32 filesystem is expected to be mounted on /mnt/boot
DISK="/dev/nvme0n1"

# Select a window manager (or both)
ENABLE_HYPRLAND=0
ENABLE_I3=0

# Enable additional features
ENABLE_GAMING=0
ENABLE_KVM=0
ENABLE_TORRENT_DL=0

# Locale configuration
LOCALES=(fr_FR.UTF-8 en_US.UTF-8)
TIMEZONE="Europe/Paris"
LANG="fr_FR.UTF-8"
KEYMAP="us"
HOSTNAME=""

# User configuration
USER_NAME="mamartin"
PASSWD=""
ROOT_PASSWD=""

# Home network
SSID=""
PSK=""

# Git
GIT_NAME="mamartin"
GIT_EMAIL=""

