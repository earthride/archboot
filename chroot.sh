#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime

hwclock --systohc

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB ISO-8859-1" >> /etc/locale.gen
locale-gen

bootctl --path=/boot install

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

echo "options root=UUID=$(lsblk -n -o UUID /dev/sda2) rw" >> /boot/loader/entries/arch.conf

passwd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm","/usr/bin/pacman -Rs" >> /etc/sudoers
useradd -m -g wheel -s /bin/bash earthride 
passwd earthride

grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color/Color/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
reflector --latest 20 --sort score --age 24 --save /etc/pacman.d/mirrorlist
pacman -S --noconfirm --needed xorg-server xorg-xinit git neovim nm-connection-editor firewalld zsh network-manager-applet bspwm feh gedit

systemctl enable fstrim.timer firewalld.service NetworkManager

mkdir -p home/earthride/.config/{bspwm,sxhkd}
cp /usr/local/share/doc/bspwm/examples/bspwmrc home/earthride/.config/bspwm/
cp /usr/local/share/doc/bspwm/examples/sxhkdrc home/earthride/.config/sxhkd/
chmod u+x home/earthride/.config/bspwm/bspwmrc
