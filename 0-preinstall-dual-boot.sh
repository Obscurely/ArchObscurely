#!/usr/bin/env bash
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo -e "-------------------------------------------------------------------------"
echo -e "-Setting up $iso mirrors for faster downloads"
echo -e "-------------------------------------------------------------------------"

reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt


echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk f2fs-tools xfsprogs

echo "--------------------------------------"
echo -e "\nFormatting disks...\n$HR"
echo "--------------------------------------"

# Create partitons
echo "Making partitions."

 # on /dev/nvme0n1 (nvme ssd)
sgdisk -n 5:0:+512M /dev/nvme0n1 # partition 1 (EFI), 1GB
sgdisk -n 3:0:+10240M /dev/sda # partition 2 (SWAP), 16GB
sgdisk -n 6:0:0 /dev/nvme0n1 # partition 3 (ROOT), 50GB
sgdisk -n 4:0:0 /dev/sda # partition 4 (HOME), the rest, 350GB+

# Set partition types
echo "Setting partition types."

 # on /dev/nvme0n1 (nvme ssd)
sgdisk -t 5:ef00 /dev/nvme0n1 # making partition 1 type efi
sgdisk -t 3:8200 /dev/sda # making partition 2 type linux swap
sgdisk -t 6:8300 /dev/nvme0n1 # making partition 3 type linux file system
sgdisk -t 4:8300 /dev/sda # making partition 4 type linux file system

# Label partitions
echo "Labeling partitions."

 # on /dev/nvme0n1 (nvme ssd)
sgdisk -c 5:"UEFISYS" /dev/nvme0n1
sgdisk -c 3:"SWAP" /dev/sda
sgdisk -c 6:"ROOT" /dev/nvme0n1 
sgdisk -c 4:"HOME" /dev/sda

# Make filesystems
echo "Making file systems."

 # on /dev/nvme0n1 (nvme ssd)
mkfs.vfat -F32 -n "UEFISYS" "/dev/nvme0n1p5" # formating efi partition with fat.
mkswap -L "SWAP" "/dev/sda3" # formating swap partition with linux swap.
mkfs.f2fs -f -l "ROOT" "/dev/nvme0n1p6" # formating root partition with f2fs.
mkfs.f2fs -f -l "HOME" "/dev/sda4" # formating home partition with f2fs.

# Mount targets
 # mount root
mount "/dev/nvme0n1p6" /mnt # mounts root
 # Create dirs for targets
mkdir /mnt/boot # makes boot dir
mkdir /mnt/home # makes home dir
 # mount other targets
mount "/dev/nvme0n1p5" /mnt/boot # mounts boot 
mount "/dev/sda4" /mnt/home # mounts home 
swapon "/dev/sda3" # turns swap on
sleep 3 # make sure everything is mounted, without can be buggy some times

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring dosfstools f2fs-tools xfsprogs grub efibootmgr wget libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
umount "/dev/nvme0n1p5" # umounts boot in order to mount when in arch-chroot for the grub installation to work.
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 0-setup       --"
echo "--------------------------------------"
