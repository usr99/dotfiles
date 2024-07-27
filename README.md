# Arch dotfiles

## Installation

Inside a tmux session, run `install.sh system`

## Monitor configuration

* Hyprland is configured to look for 2 monitors:
* `hyprctl monitors` will list monitors and their name
```
# hypr/vars.conf
$mon1 = HDMI-A-1
$mon2 = DVI-D-1 
```

## Useful packages

* `sane-airscan` to scan documents with a local/remote device

## Keybinds

### Hyprland
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
##### Workspaces
* SUPER + {1-9}             Move to workspace X
* SUPER + SHIFT + {1-9}     Move window to workspace X

##### Screenshot
* SUPER + Print             Screenshot the entire screen
* SUPER + SHIFT + Print     Screenshot an area of the screen
* ALT + Print               Save the last screenshot as ~/Pictures/screen.png 

### tmux
* CTRL + X                  Prefix combination
* PREFIX + {-,|}            Split planes h/v
* PREFIX + Z                Zoom active pane
* PREFIX + C                Create window
* PREFIX + X                Kill pane
* PREFIX + &                Kill window
* CTRL + {h,j,k,l}          Move focus between panes
* ALT + SHIFT + {h,l}       Move focus between windows

### alacritty
* CTRL + {0,-,+}            Edit font size

