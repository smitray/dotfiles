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
installPackages basePackages