#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

sgdisk --zap-all "$1"
wipefs -a "$1"

timedatectl set-ntp true

sgdisk -og "$1"
sgdisk -n 1:0:+550MiB -c 1:"EFIBOOT" -t 1:ef00 "$1"
sgdisk -n 2:0:+15GiB -c 2:"root" -t 2:8304 "$1"
sgdisk -n 3:0:+4GiB -c 3:"/tmp" -t 3:8300 "$1"
sgdisk -n 4:0:+4GiB -c 4:"/home" -t 4:8302 "$1"

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
mkdir -p /mnt/tmp
mount /dev/sda3 /mnt/tmp
mkdir -p /mnt/home
mount /dev/sda4 /mnt/home

pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1

pacstrap /mnt base linux linux-firmware intel-ucode sudo networkmanager reflector

genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/earthride/archboot/master/chroot.sh > /mnt/chroot.sh
arch-chroot /mnt bash ./chroot.sh && rm /mnt/chroot.sh

umount -R /mnt
