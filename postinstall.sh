#!/bin/sh
sudo pacman -Sy --needed --noconfirm git
git clone https://github.com/xetrazxz/archinstallps.git ~/archinstallps
cd ~/archinstallps
scriptdir=~/archinstallps/
sh $scriptdir/files/setup.sh
