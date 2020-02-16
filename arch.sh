#!/usr/bin/env bash

function pause(){
   read -p "$*"
}

timedatectl set-ntp true

sgdisk -og "$1"
sgdisk -n 1:0:+550MiB -c 1:"EFIBOOT" -t 1:ef00 "$1"
sgdisk -n 2:0:+2GiB -c 2:"root" -t 2:8304 "$1"
sgdisk -n 3:0:+3GiB -c 3:"/tmp" -t 3:8300 "$1"
sgdisk -n 4:0:+4GiB -c 4:"/home" -t 4:8302 "$1"
sgdisk -p "$1"

mkfs.fat -F32 "/dev/sda1"
mkfs.ext4 "/dev/sda2"
mkfs.ext4 "/dev/sda3"
mkfs.ext4 "/dev/sda4"

mount "/dev/sda2" /mnt
mkdir -p /mnt/boot
mount "/dev/sda1" /mnt/boot
mkdir -p /mnt/tmp
mount "/dev/sda3" /mnt/tmp
mkdir -p /mnt/home
mount "/dev/sda4" /mnt/home

pause 'Done Partitioning. Press [Enter] to continue...'

pacstrap /mnt base linux linux-firmware intel-ucode 

genfstab -U /mnt >> /mnt/etc/fstab

pause 'Chrooting into the system. Press [Enter] to continue...'

curl https://raw.githubusercontent.com/earthride/archboot/master/chroot.sh > /mnt/chroot.sh \
&& arch-chroot /mnt bash chroot.sh && rm /mnt/chroot.sh

arch-chroot /mnt 

ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime

hwclock --systohc

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB ISO-8859-1" >> /etc/locale.gen
locale-gen

pacman --noconfirm --needed -S networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

pause 'Setting up the bootloader. Press [Enter] to continue...'

bootctl --path=/boot install

pause 'Adding entries. Press [Enter] to continue...'

cat << 'EOF' > /boot/loader/loader.conf
default arch
timeout 3
console-mode max
editor no
EOF

cat << 'EOF' > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
EOF

echo "options root=UUID=$(lsblk -n -o UUID /dev/nvme0n1p2) rw" >> /boot/loader/entries/arch.conf

pause 'Done. Press [Enter] to continue...'

