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
'zoom' # video conferences
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

# Upgrade with yay
yay -Syyu --noconfirm

# copy over dotfiles
export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchObscurely/dotfiles/* $HOME/.config/
sleep 1

# basic config bspwm
install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc
mkdir ~/.config/polybar/
cp /usr/share/doc/polybar/config ~/.config/polybar/config
systemctl enable lightdm

echo -e "\nDone!\n"
exit
