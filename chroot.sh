function pause(){
   read -p "$*"
}

pause 'Setting locales. Press [Enter] to continue...'

ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime

hwclock --systohc

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB ISO-8859-1" >> /etc/locale.gen
locale-gen

#pacman --noconfirm --needed -S networkmanager
#systemctl enable NetworkManager
#systemctl start NetworkManager

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

echo "options root=UUID=$(lsblk -n -o UUID /dev/sda2) rw" >> /boot/loader/entries/arch.conf

pause 'Done. Press [Enter] to continue...'
