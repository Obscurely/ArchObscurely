#!/usr/bin/env bash

echo -e "\nINSTALLING AUR SOFTWARE\n"
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "CLONING: YAY"
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
ln -s "$HOME/zsh/.zshrc" $HOME/.zshrc

PKGS=(
'autojump' # zsh autojump
'awesome-terminal-fonts' # font
'brave-bin' # Brave Browser
'dxvk-bin' # DXVK DirectX to Vulcan
'github-desktop-bin' # Github Desktop sync
'haruna' # video player
'mangohud' # Gaming FPS Counter
'mangohud-common' # mangohud utils
'nerd-fonts-fira-code' # font
'noto-fonts-emoji' # font
'polybar' # fast, easy to use tool for creating status bars
'ocs-url' # install packages from websites
'ttf-droid' # font
'ttf-hack' # font
'ttf-meslo' # Nerdfont package
'ttf-ms-fonts' # fonts
'ttf-roboto' # font
'waterfox-g4-bin' # waterfox browser (firefox without mozzila)
'zoom' # video conferences
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

# Upgrade with yay
yay -Syyu --noconfirm

echo "Customizing system"

# copy backgrounds to their folder and link them
cp $HOME/ArchObscurely/background.jpg $HOME/Documents
sudo ln -s "$HOME/Documents/background.jpg" /usr/share/backgrounds/background.jpg

# installing polybar themes
cd $HOME/Downloads/
git clone --depth=1 https://github.com/adi1090x/polybar-themes.git
cd polybar-themes
chmod +x setup.sh
./setup.sh
sleep 3 # wait 3 to make sure it installed

# copy lightdm config
cd $HOME/Downloads/
wget git.io/webkit2 -O theme.tar.gz
mkdir glorious
mv theme.tar.gz glorious/
cd glorious
tar zxvf theme.tar.gz
rm theme.tar.gz
cd ..
sudo mv glorious/ /usr/share/lightdm-webkit/themes/
sudo cp $HOME/ArchObscurely/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
sudo cp $HOME/ArchObscurely/lightdm/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf

# installing rofi themes
cd $HOME/Downloads/
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
sleep 3 # wait 3 to make sure it installed

# install grub sleek theme dark
cd $HOME/Downloads/
git clone https://github.com/sandesh236/sleek--themes
cd sleek--themes
chmod +x install.sh
sudo ./install.sh
sleep 3 # wait 3 to make sure it installed

# install fluentdark theme
cd $HOME/Downloads/
git clone https://github.com/vinceliuice/Fluent-gtk-theme
cd Fluent-gtk-theme
chmod +x install.sh
./install.sh -c dark -s standard
sleep 3 # wait 3 to make sure it installed

# copy over dotfiles
export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchObscurely/dotfiles/* $HOME/.config/
sleep 3 # wait 3 to make sure it copyed

# installing nvidia-tkg driver
cd $HOME/Downloads/
git clone https://github.com/Frogging-Family/nvidia-all.git
cd nvidia-all
makepkg -si

echo -e "\nDone!\n"
exit
