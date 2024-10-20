#!/bin/bash
# add base-devel, git, wget, curl, nvim, nano, archlinux-keyring in a list
# check if the package is already installed otherwise install all the packages in the list and log the output in logs folder

basePackages=(
    base-devel
    git
    wget
    curl
    neovim
    nano
    archlinux-keyring
    reflector
)

echo -e "${INFO} Installing base packages"

#Use installPackages function to install packages
installPackages "${basePackages[@]}"


echo -e "${INFO} Updating mirrorlist for India" | tee -a "${logs}/mirrorlist-$(date +"%Y%m%d-%H%M%S").log"
sudo reflector --country India --latest 5 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo -e "${INFO} Chaotic AUR repository"
if grep -q "chaotic-aur" /etc/pacman.conf; then
    echo "Chaotic AUR repository already exists" | tee -a "${logs}/01-chaotic-aur-$(date +"%Y%m%d-%H%M%S").log"
else
    echo "Chaotic AUR repository not found, installing..." | tee -a "${logs}/01-chaotic-aur-$(date +"%Y%m%d-%H%M%S").log"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    echo -e "${INFO} Updating the system" | tee -a "${logs}/01-chaotic-aur-$(date +"%Y%m%d-%H%M%S").log"
    sudo pacman -Syu --noconfirm
fi