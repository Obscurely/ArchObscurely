#!/bin/bash

bash 0-preinstall.sh
cp -r /root/ArchObscurely /mnt/root
arch-chroot /mnt /root/ArchObscurely/1-setup.sh
source /mnt/root/ArchObscurely/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchObscurely/2-user.sh
arch-chroot /mnt /root/ArchObscurely/3-post-setup.sh
