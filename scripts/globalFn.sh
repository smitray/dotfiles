#!/bin/bash
#List of all the global functions used in the scripts

#Write a function to check whether the sub-script is available or not
#If the script is available then make it executable and execute it

function runScript() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        echo -e "${INFO} Running $1"
        echo -e "${INFO} Running $1" | tee -a "${logs}/00-globalFn-runScript-$(date +"%Y%m%d-%H%M%S").log"
        source "$1"
    else
        echo -e "${ERROR} $1 not found" | tee -a "${logs}/00-globalFn-runScript-$(date +"%Y%m%d-%H%M%S").log"
        exit 1
    fi
}

#Write a function to install packages with following conditions:
#Input is a list of packages
#check if the package is already installed
#If not installed then check whether the package is available in pacman or aur or chaotic-aur
#If available then install the package and log the output of the installation
#If not available then log the error message

function installPackages() {
    local pkgList=("$@")
    for pkg in "${pkgList[@]}"; do
        if ! pacman -Qq "$pkg" &>/dev/null; then
            echo -e "${INFO} Installing $pkg" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
            if pacman -Ss "$pkg" &>/dev/null; then
                sudo pacman -S --noconfirm "$pkg" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
            elif yay -Ss "$pkg" &>/dev/null; then
                yay -S --noconfirm "$pkg" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
            elif chaotic-aur -Ss "$pkg" &>/dev/null; then
                chaotic-aur -S --noconfirm "$pkg" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
            else
                echo -e "${ERROR} $pkg not found" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
            fi
        else
            echo -e "${SUCCESS} $pkg is already installed" | tee -a "${logs}/03-packageInstall-$(date +"%Y%m%d-%H%M%S").log"
        fi
    done
}