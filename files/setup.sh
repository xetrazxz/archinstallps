#!/bin/bash

packagedir=~/archinstallps/files/packages/

echo "Vulkan Driver ....."

sudo pacman -S --needed --noconfirm $(cat $packagedir/packages_drivers.txt)
sudo pacman -S --needed --noconfirm $(cat $packagedir/packages_gaming.txt)
#yay -S --needed --noconfirm $(cat $packagedir/packages_aur.txt)

curl https://raw.githubusercontent.com/xetrazxz/dotfiles/refs/heads/main/install.sh | sh

yay -S thorium-browser-bin --noconfirm
