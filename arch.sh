#!usr/bin/bash

sgdisk -og $1
sgdisk -n 1:0:+1MiB -c 1:"BIOS Boot Partition" -t 1:ef02 $1
sgdisk -n 2:0:+550MiB -c 2:"EFI System Partition" -t 2:ef00 $1
sgdisk -n 3:0:+2GiB -c 3:"Linux /root" -t 3:8304 $1
sgdisk -n 4:0:+3GiB -c 4:"/var" -t 4:8300 $1
sgdisk -n 5:0:+4GiB -c 5:"/tmp" -t 5:8300 $1
sgdisk -n 6:0:+5GiB -c 6:"Linux /home" -t 6:8302 $1
sgdisk -p $1
