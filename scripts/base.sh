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
)

echo -e "${INFO} Installing base packages"
for pkg in "${basePackages[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        echo -e "${INFO} Installing $pkg"

        sudo pacman -S --noconfirm "$pkg" | tee -a "${logs}/01-base-$(date +"%Y%m%d-%H%M%S").log"
    else
        echo -e "${SUCCESS} $pkg is already installed" | tee -a "${logs}/01-base-$(date +"%Y%m%d-%H%M%S").log"
    fi
done