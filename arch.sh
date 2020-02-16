#!/usr/bin/env bash

timedatectl set-ntp true

sgdisk -og "$1"
sgdisk -n 1:0:+550MiB -c 1:"EFIBOOT" -t 1:ef00 "$1"
sgdisk -n 2:0:+2GiB -c 2:"root" -t 2:8304 "$1"
sgdisk -n 3:0:+3GiB -c 3:"/tmp" -t 3:8300 "$1"
sgdisk -n 4:0:+4GiB -c 4:"/home" -t 4:8302 "$1"
sgdisk -p "$1"

mkfs.fat -F32 "$1p1"
mkfs.ext4 "$1p2"
mkfs.ext4 "$1p3"
mkfs.ext4 "$1p4"

mount "$1p2" /mnt
mkdir -p /mnt/boot
mount "$1p1" /mnt/boot
mkdir -p /mnt/tmp
mount "$1p3" /mnt/tmp
mkdir -p /mnt/home
mount "$1p4" /mnt/home

pacman -Sy --noconfirm archlinux-keyring

pacstrap /mnt base linux linux-firmware intel-ucode 

genfstab -U /mnt >> /mnt/etc/fstab

clear
