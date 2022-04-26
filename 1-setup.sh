#!/usr/bin/env bash
mount "/dev/nvme0n1p1" /boot # remounts boot in order to install grub
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
iso=$(curl -4 ifconfig.co/country-iso)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/Bucharest
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
ln -s /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc --utc

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# Enable chaotic-aur
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
sleep 3 # making sure the file actually got changed, without can be buggy some times for some reason

# updating pacman in order to download lates packages
pacman -Sy archlinux-keyring ---noconfirm
pacman -Sy # another one to chaotic-aur database

echo -e "\nInstalling Base System\n"

PKGS=(
'mesa' # Essential Xorg First
'xorg' # xorg base
'xorg-server' # xorg base
'xorg-apps' # xorg base
'xorg-drivers' # xorg base
'xorg-xkill' # xorg base
'xorg-xinit' # xorg base
'xterm' # xorg base
'alsa-lib' # sound lib
'alsa-plugins' # audio plugins
'alsa-utils' # audio utils
'autoconf' # build
'automake' # build
'base' # essential
'base-devel' # essential
'bash-completion' # essential
'bind' # dns server
'binutils' # gnu collection of utils
'bleachbit' # os cleaner
'bridge-utils' # virtualization
'btrfs-progs' # btrfs file support
'bspwm' # tiling window manager
'clementine' # music player
'code' # Visual Studio code
'cronie' # cron task server
'dbus' # os's dbus
'dialog' # dialog boxes for script
'discord' # discord client
'dnsmasq' # virtualization
'dosfstools' # fat32 file support
'easyeffects' # audio effects
'efibootmgr' # EFI boot
'ebtables' # virtualization
'exfat-utils' # exfat file support
'feh' # sets wallpaper
'flameshot' # screenshot daemon
'fuse2' # fuse
'fuse3' # fuse
'fuseiso' # fuse
'gamemode' # gamemode utility (for boosting game performance)
'gcc' # gcc compiler
'giflib' # wine dependency
'gimp' # Photo editing
'git' # git cli
'gnome-calculator' # powerful calculator
'gnome-keyring' # gnome's keyring
'gnu-free-fonts' # fonts
'gnutls' # free implementation of tls, ssl and dtls protocols
'go' # for compiling yay
'gtk3' # gtk3 widget toolkit
'gsfonts' # fonts
'gst-plugins-base' # gst base plugins
'gst-plugins-base-libs' # gst libs for base plugins
'gparted' # partition management
'gptfdisk' # gpt disk tool
'grub' # grub bootloader
'grub-customizer' # app to customize grub
'gst-libav' # gst libav
'gst-plugins-good' # gst plugins good
'gst-plugins-ugly' # gst plugins ugly
'gvfs' # thunar trash support etc
'haveged' # antropy generator
'htop' # console procces viewer
'inkscape' # for compiling the cursor and useful for other themes
'iptables-nft' # iptables nft
'jdk-openjdk' # Java 17
'kdenlive' # video editor
'keepassxc' # offline password manager
'kitty' # terminal
'legendary' # epic games cli interface
'lib32-alsa-lib' # sound lib32
'lib32-alsa-plugins' # sound lib32
'lib32-libpng' # lib for png files
'lib32-libldap' # wine dependency
'lib32-giflib' # wine dependency
'lib32-gnutls' # gnutls lib32
'lib32-openal' # wine dependency
'lib32-v4l-utils' # lib32 for video related stuff
'lib32-libpulse' # sound lib32
'lib32-libgpg-error' # wine dependency
'lib32-libjpeg-turbo' # jpeg lib
'lib32-sqlite' # sqlite lib
'lib32-libxcomposite' # wine dependency
'lib32-libgcrypt' # wine dependency
'lib32-libxinerama' # wine dependency
'lib32-ncurses' # wine dependency
'lib32-mpg123' # wine dependency
'lib32-opencl-icd-loader' # wine dependency
'lib32-v4l-utils' # wine dependency
'lib32-libxslt' # wine dependency
'lib32-libva' # wine dependency
'lib32-gtk3' # gtk3 lib32
'lib32-gst-plugins-base-libs' # gst plugins base libs
'lib32-vulkan-icd-loader' # wine dependency
'libjpeg-turbo' # wine dependency
'libdbusmenu-glib' # dbus lib
'libgpg-error' # wine dependency
'libldap' # wine dependency
'libpng' # png lib
'libpulse' # sound lib
'libxcomposite' # wine dependency
'libxinerama' # wine dependency
'libguestfs' # virtualization
'libva' # wine dependency
'libgcrypt' # wine dependency
'libxslt' # wine dependency
'libnewt' # system lib
'libtool' # programming lib
'lightdm' # lightweight display manager
'lightdm-webkit2-greeter' # greeter for lightdm
'linux-zen' # linux zen kernel
'linux-firmware' # firmware filex for linux
'linux-zen-headers' # linux zen kernel headers
'linux-tkg-pds' # linux tkg kernel with pds cpu scheduler
'linux-tkg-pds-headers' # linux tkg kernel with pds cpu scheduler headers
'lutris' # lutris client
'lxappearance' # configure os appearance
'lxsession' # polkit authentification agent
'lzop' # compression
'make' # make util for building code
'milou' # arm build system
'mpg123' # wine dependency
'nano' # essential
'ncdu' # console utils for viewing where all disk space goes
'ncurses' # wine dependency
'notepadqq' # good text editor (similar to notepad++ in windows)
'noto-fonts' # fonts
'nvidia-dkms' # nvidia dkms driver (for custom kernels)
'neofetch' # dispalys system info
'networkmanager' # network managment
'ntfs-3g' # ntfs file support
'openssh' # server ssh
'os-prober' # scans for any other os (for grub boot)
'obs-studio' # recodring software
'obsidian' # great taking notes app
'onlyoffice' # good office suite
'openal' # wine dependency
'openbsd-netcat' # virtualizatoin
'opencl-icd-loader' # wine dependency
'p7zip' # compression
'pacman-contrib' # essential
'papirus-icon-theme' # icons theme
'pavucontrol' # audio panel
'peazip' # archive manager
'postman' # software for sending http requests
'powerpill' # pacman that download's from multiple mirrors
'python' # python binaries
'powerline-fonts' # fonts
'pipewire' # sound
'pipewire-pulse' # sound
'pipewire-alsa'	 # sound
'python-pip' # python's pip utility
'qbittorrent' # torrent software
'qemu' # virtualization
'ristretto' # image viewer
'rofi' # window switcher
'rsync' # sync files
'steam' # steam client
'sdl_ttf' # some sort of font lib
'speedtest-cli' # test network speed
'sqlite' # sqlite binaries
'systemd' # systemd, don't need to say more
'sudo' # sudo, don't need to say more
'swtpm' # tpm emulator
'sxhkd' # x hotkey daemon (by bspwm devs)
'terminus-font' # font
'thunar' # file manager (from xfce)
'tint2' # lightweight panel for xorg
'traceroute' # trace network route
'ttf-bitstream-vera' # font
'ttf-dejavu' # font
'ttf-fira-code' # font
'ttf-font-awesome' # font
'ttf-hack' # font
'ttf-liberation' # font
'ttf-roboto' # font
'ttf-ubuntu-font-family' # font
'ufw' # firewall
'ungoogled-chromium' # chromium browser without google's shit
'unrar' # compression
'unzip' # compression
'usbutils' # essential
'vim' # essential
'v4l-utils' # wine dependency
'vde2' # virtualization
'virt-manager' # virtualization
'virt-viewer' # virtualization
'vulkan-icd-loader' # wine dependency
'wget' # wget, download's stuff from web
'which' # util to show full paths of commands
'wine-gecko' # wine related
'wine-mono' # wine related
'winetricks' # wine related
'wine-tkg-staging-fsync-git' # wine
'xdg-user-dirs' # creates user dirs
'xf86-input-libinput' # input driver
'xfce4-settings' # settings app
'xorg-fonts-type1' # fon ts
'zeroconf-ioslave' # zeroconf support
'zip' # compression
'zsh' # zsh shell
'zsh-syntax-highlighting' # zsh systax highlightning
'zsh-autosuggestions' # zsh autosuggestion
'zenity' # wine dependency
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
#
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm --needed intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm --needed amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia-dkms --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"

echo "--------------------------------------"
echo "--   Bootloader Grub Installation   --"
echo "--------------------------------------"
# Set up mkinitcpio for nvme
sed -i "s/MODULES=()/MODULES=(nvme)/g" /etc/mkinitcpio.conf
mkinitcpio -p linux
# Install and config grub
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Create user
if ! source install.conf; then
	read -p "Please enter username:" username
echo "username=$username" >> /root/ArchObscurely/install.conf
fi
if [ $(whoami) = "root"  ];
then
 	groupadd libvirt
    useradd -m -G wheel,libvirt -s /bin/bash $username
	passwd $username
	cp -R /root/ArchObscurely /home/$username/
    chown -R $username: /home/$username/ArchObscurely
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi
