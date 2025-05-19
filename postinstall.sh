#!/bin/sh
sudo pacman -Sy --needed --noconfirm git
git clone https://github.com/xetrazxz/archinstallps.git ~/archinstallps
cd ~/archinstallps
scriptdir=~/archinstallps/scripts

sh $scriptdir/drivers.sh
sh $scriptdir/gaming_packages.sh
curl https://raw.githubusercontent.com/xetrazxz/dotfiles/refs/heads/main/install.sh | sh
sh $scriptdir/aur.sh
