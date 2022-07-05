#!/usr/bin/env bash

echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------

echo -e "\nCopying xorg conf to fix lightdm multi monitor setup"

sudo cp $HOME/ArchObscurely/xorg/52-resolution-fix.conf /etc/X11/xorg.conf.d/.

echo -e "\nEnabling essential services"

sudo ntpd -qg
sudo systemctl enable lightdm
sudo systemctl enable ntpd.service
sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable libvirtd.service

echo -e "\nAdding current user to libvirtd group"
sudo usermod -G libvirt -a $(whoami)

echo "-------------------------------------------------"
echo "               Tweaking Arch a bit               "
echo "-------------------------------------------------"
# increase file watcher count
# this prevents a "too many files" error in Visual Studio Code
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system
# Pulse audio loads the `esound-protocol` module, which best I can tell is rarely needed.
# That module creates a file called `.esd_auth` in the home directory which I'd prefer to not be there. So...
sudo sed -i 's|load-module module-esound-protocol-unix|#load-module module-esound-protocol-unix|g' /etc/pulse/default.pa

# Gaming optimizations
PKGS=(
  'gamemode'
  'wine-tkg-fsync-git'
  'auto-cpufreq'
  'vkBasalt'
  'goverlay'
  'earlyoom'
  'ananicy-git'
  'libva-vdpau-driver'
)

# PS3='Please enter your GPU choice: '
# options=("Nvidia-tkg" "AMDGPU" "Quit")
# select opt in "${options[@]}"
# do
#     case $opt in
#         "Nvidia-tkg")
#             echo "You chose Nvidia-tkg"
#             $nvidia = true
#             git clone https://github.com/Frogging-Family/nvidia-all.git
#             cd nvidia-all
#             makepkg -si
#             ;;
#         "AMDGPU")
#             echo "You chose AMDGPU"
#             pacman -S xf86-video-amdgpu --noconfirm --needed
#             ;;
#         "Continue"|"Q"|"Quit"|*)
#             break
#             ;;
#         *) echo "invalid option $REPLY";;
#     esac
# done

for PKG in "${PKGS[@]}"; do
  echo "INSTALLING: ${PKG}"
  yay -S "$PKG" --noconfirm --needed
done

echo -e "\nEnableing Services and Tweaking\n"

systemctl --user enable gamemoded && systemctl --user start gamemoded
systemctl enable --now earlyoom
sudo sysctl -w net.core.netdev_max_backlog = 16384
sudo sysctl -w net.core.somaxconn = 8192
sudo sysctl -w net.core.rmem_default = 1048576
sudo sysctl -w net.core.rmem_max = 16777216
sudo sysctl -w net.core.wmem_default = 1048576
sudo sysctl -w net.core.wmem_max = 16777216
sudo sysctl -w net.core.optmem_max = 65536
sudo sysctl -w net.ipv4.tcp_rmem = 4096 1048576 2097152
sudo sysctl -w net.ipv4.tcp_wmem = 4096 65536 16777216
sudo sysctl -w net.ipv4.udp_rmem_min = 8192
sudo sysctl -w net.ipv4.udp_wmem_min = 8192
sudo sysctl -w net.ipv4.tcp_fastopen = 3
sudo sysctl -w net.ipv4.tcp_max_syn_backlog = 8192
sudo sysctl -w net.ipv4.tcp_max_tw_buckets = 2000000
sudo sysctl -w vm.swappiness = 10

# Clean up temp folder
rm -rf /home/$(whoami)/Documents/temp

# Setup UFW rules
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "
###############################################################################
# Cleaning
###############################################################################
"
# Delete left over folders
sudo rm -rf /home/$(whoami)/Downloads/*
sudo rm -rf /home/$(whoami)/ArchObscurely
sudo rm -rf /home/$(whoami)/yay
sudo rm -rf /home/$(whoami)/go

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
