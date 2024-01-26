# Arch dotfiles

## Requirements
The installation works only for UEFI boot.  
If you use BIOS, manual modifications of the install script is required.

## Installation

### Using official arch image
Follow the first steps of the archlinux guide to prepare an installation medium.
After booting, connect to the internet and clone this repository.
Edit `./scripts/config.sh` to configure your installation process, then run:

```zsh
cd dotfiles
./scripts/install.sh
```

### Using custom arch image
Clone this repo in your working directory.
Make sure the `extra/archiso` package is installed then copy the iso source files.

```zsh
cd dotfiles
cp -r /usr/share/archiso/configs/releng ./archlive
cp ./scripts/* ./archlive/airootfs/root
```

Edit `./archlive/airootfs/root/config.sh` to configure your installation process, then run:

```zsh
sudo mkarchiso -v -w /tmp/archiso-dotfiles ./archlive
```

If successful, you should find a .iso file in the `./out` directory.
Boot using this generated iso then run `./install.sh`.

