#!/bin/bash
set -e

echo "Starting full Arch install..."

# 0 - Partition disk (no labels)

lsblk /dev/sda

# 1 - Format and mount partitions, create subvolumes
echo "Formatting EFI and root partitions..."
mkfs.btrfs -f -L archlinux /dev/sda

echo "Creating Btrfs subvolumes..."
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@var-cache
btrfs subvolume create /mnt/@var-log
umount /mnt

echo "Mounting subvolumes..."
mount -o noatime,autodefrag,compress=lzo,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{efi,home,.snapshots,swap,var/cache,var/log}

mount -o noatime,compress=lzo,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=lzo,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,compress=lzo,subvol=@snapshots /dev/sda2 /mnt/swap
mount -o noatime,compress=lzo,subvol=@var-cache /dev/sda2 /mnt/var/cache
mount -o noatime,compress=lzo,subvol=@var-log /dev/sda2 /mnt/var/log

mount /dev/sda1 /mnt/efi

btrfs filesystem mkswapfile --size 8G /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# 2 - Install base system
echo "Installing base system..."
pacstrap -K /mnt base linux-zen linux-firmware amd-ucode


# 3 - Generate fstab
echo "Generating fstab..."
genfstab -U /mnt > /mnt/etc/fstab

# 4 - Chroot configuration & Packges
echo "Configuring system in chroot..."
arch-chroot /mnt /bin/bash <<EOF

pacman -S --noconfirm btrfs-progs grub efibootmgr vim base-devel linux-zen-headers

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "archlinux" > /etc/hostname

echo -e "KEYMAP=us\nFONT=lat9w-16" > /etc/vconsole.conf
EOF

# Set root password
arch-chroot /mnt /bin/bash -c "echo 'root:$ROOT_PASS' | chpasswd"

# 5 - Install and configure bootloader
echo "Installing GRUB bootloader..."
arch-chroot /mnt /bin/bash <<EOF
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# 6 - Create user and enable network services
echo "Creating user and enabling network..."
arch-chroot /mnt /bin/bash -c "useradd -m -G wheel xetra && echo 'xetra:$USER_PASS' | chpasswd"
arch-chroot /mnt /bin/bash -c "echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers"
arch-chroot /mnt /bin/bash -c "pacman -Sy --noconfirm dhcpcd iwd && systemctl enable dhcpcd && systemctl enable iwd"

# Finish
echo "Installation complete! You can now reboot."
umount -R /mnt
reboot
