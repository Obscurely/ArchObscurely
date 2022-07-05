#!/usr/bin/env bash

# Making xdg dirs manually (also in the dotfiles it's the config for them), this prevents errors where the package wouldn't create the dirs
mkdir $HOME/Desktop
mkdir $HOME/Downloads
mkdir $HOME/Templates
mkdir $HOME/Public
mkdir $HOME/Documents
mkdir $HOME/Music
mkdir $HOME/Pictures
mkdir $HOME/Videos

# Cache and .config dirs, in order to avoid any errors
mkdir $HOME/.config
mkdir $HOME/.cache

# Dir where flameshot saves screenshots
mkdir $HOME/Pictures/screenshots

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
  'autojump'               # zsh autojump
  'awesome-terminal-fonts' # font
  'dxvk-bin'               # DXVK DirectX to Vulcan
  'haruna-git'             # video player
  'mangohud'               # Gaming FPS Counter
  'mangohud-common'        # mangohud utils
  'mat2'                   # metadata remover tool
  'nerd-fonts-fira-code'   # font
  'netdiscover'            # utility for scanning local network
  'noto-fonts-emoji'       # font
  'paru'				   # Like yay but coded in rust, I like it more, but for stability sake I use yay to install system
  'polybar'                # fast, easy to use tool for creating status bars
  'picom-jonaburg-fix'     # xorg compositor (picom with rounded corners support and some fixes)
  'sonixd'                 # app to interact with my self hosted instance of navidrome (music server w/ web interface)
  'ttf-droid'              # font
  'ttf-hack'               # font
  'ttf-iosevka-nerd'       # nerd font for polybar
  'ttf-meslo'              # Nerdfont package
  'ttf-ms-fonts'           # fonts
  'ttf-roboto'             # font
  'waterfox-g4-bin'        # waterfox browser (firefox without mozzila)
  'zoom'                   # video conferences
)

for PKG in "${PKGS[@]}"; do
  yay -S --noconfirm $PKG --needed
done

# Upgrade with yay
yay -Syyu --noconfirm

echo "Customizing system"

# copy backgrounds to their folder and link them
cp $HOME/ArchObscurely/background.jpg $HOME/Documents/background.jpg
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
cd "Sleek theme-dark"
chmod +x install.sh
sudo ./install.sh
sleep 3 # wait 3 to prevent any issues
sudo ./install.sh # run again install since there seems, at least at the time of this commit, to be a bug and not work straight up
sleep 3 # wait 3 to finish process and prevent issues

# install fluentdark theme
cd $HOME/Downloads/
git clone https://github.com/vinceliuice/Fluent-gtk-theme
cd Fluent-gtk-theme
chmod +x install.sh
./install.sh -c dark -s standard
sleep 3 # wait 3 to make sure it installed

# install volante cursor theme
cd $HOME/Downloads/
git clone https://github.com/varlesh/volantes-cursors.git
cd volantes-cursors
make build
sudo make install

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
