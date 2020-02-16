ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime

hwclock --systohc

echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB ISO-8859-1" >> /etc/locale.gen
locale-gen

echo "KEYMAP=uk" >> /etc/vconsole.conf

pacman --noconfirm --needed -S networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

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

echo "options root=UUID=$(lsblk -n -o UUID /dev/nvme0n1p2) rw" >> /boot/loader/entries/arch.conf
