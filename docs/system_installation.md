* if azerty keyboard
    * loadkeys fr

* check the system is booted in UEFI mode
    * cat /sys/firmware/efi/fw_platform_size
    * should return 64 or 32 depending on your system

* for wireless connect with iwctl

* update system clock
    * timedatectl set-timezone Europe/Paris

* partitioning
* fdisk /dev/yourdisk
    * Arch only
        * EFI system    | 512M
        * swap          | 4G
        * filesystem    | remainder
    * Dual boot windows
        * see https://wiki.archlinux.org/title/Dual_boot_with_Windows_(Fran%C3%A7ais)#Syst%C3%A8mes_UEFI
        * You should already have an EFI partition
            * I recommend to make it 1G to be safe
            * you don't want to lack space, trust me
        * same as above for swap and filesystem
        * make sure you disabled Secure Boot and Windows Fast Startup
    * Formatting
        * mkfs.ext4 *filesystem*
        * mkswap *swap*
        * if you created your esp in the last step
            * mkfs.fat -F 32 *esp*
    * Mounting
        * mount *filesystem* /mnt
        * mount --mkdir *esp* /mnt/boot
        * swapon *swap*

* pacstrap -K /mnt
    * base linux linux-firmware
    * grub efibootmgr (+ os-prober to detect other systems)
    * vim
    * man-pages man-db texinfo 
    * iwd networkmanager dhcpcd openssh
    * intel-ucode or amd-ucode (depending on your CPU)
    * nvidia-dkms (if you have a nvidia GPU)
    * linux-headers

* genfstab -U /mnt >> /mnt/etc/fstab
* arch-chroot /mnt
* ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
* hwclock --systohc
* uncomment en_US and fr_FR in /etc/locale.gen
    * run locale-gen
* echo LANG=fr_FR.UTF-8 > /etc/locale.conf
* echo KEYMAP=us > /etc/vconsole.conf
* echo archwin > /etc/hostname
* set root password
    * passwd
* uncomment ParallelDownloads in /etc/pacman.conf

* consult https://wiki.archlinux.org/title/GRUB#Configuration
* grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
* in /etc/default/grub
    * automatically create boot entries for other systems
        * uncomment/add GRUB_DISABLE_OS_PROBER=false
    * for nvidia GPU
        * append nvidia_drm.modeset=1 to GRUB_CMDLINE_LINUX_DEFAULT
* grub-mkconfig -o /boot/grub/grub.cfg
* finish nvidia drivers setup
    * in /etc/mkinitcpio.conf
        * add nvidia nvidia_modeset nvidia_uvm nvidia_drm to MODULES
    * mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    * echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf
    * find more info there https://wiki.hyprland.org/Nvidia/

* leave arch-chroot
* umount -R /mnt
* reboot
    * you might need to make GRUB your default boot

* check microcode update
* journalctl -k --grep=microcode
* test your network with ping
* edit /etc/resolv.conf if you have DNS issues

