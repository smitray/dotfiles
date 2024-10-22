#!/bin/bash

# Essential base packages list
basePackages=(
    base-devel
    git
    wget
    curl
    neovim
    nano
    archlinux-keyring
    reflector
    sudo
    openssh
    rsync
)

# Function to check if Chaotic-AUR is already installed
is_chaotic_aur_installed() {
    grep -q "\[chaotic-aur\]" /etc/pacman.conf
}

# Function to install Chaotic-AUR if it's not installed
install_chaotic_aur() {
    echo -e "${BLUE}Chaotic-AUR is not installed. Installing now...${RESET}"
    logger "chaotic-aur" "[INFO]: Chaotic-AUR is not installed. Installing now..."

    # Add the Chaotic-AUR keyring and repository
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'

    #Backup the pacman.conf file before proceeding
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak

    # Add Chaotic-AUR repository to pacman.conf
    sudo tee -a /etc/pacman.conf >/dev/null <<EOL

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOL

    # Synchronize package databases
    echo -e "${BLUE}Synchronizing package databases...${RESET}"
    logger "chaotic-aur" "[INFO]: Synchronizing package databases..."
    sudo pacman -Sy

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Chaotic-AUR repository added successfully.${RESET}"
        logger "chaotic-aur" "[SUCCESS]: Chaotic-AUR repository added successfully."
    else
        echo -e "${RED}Failed to synchronize package databases.${RESET}"
        logger "chaotic-aur" "[FAILED]: Failed to synchronize package databases."
        exit 1
    fi
}

# Main setup function to configure the base system
setup_base() {
    echo -e "${BLUE}Starting base system setup...${RESET}"
    logger "baseSetup" "[INFO]: Starting base system setup..."

    # Step 1: Install essential base packages
    echo -e "${BLUE}Installing base packages...${RESET}"
    installPackages "${basePackages[@]}"

    # Step 2: Update mirrorlist for India
    # echo -e "${BLUE}Updating mirrorlist for India...${RESET}"
    # logger "mirrorlist" "[INFO]: Updating mirrorlist for India..."
    # sudo reflector --country India --latest 5 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # if [[ $? -eq 0 ]]; then
    #     echo -e "${GREEN}Mirrorlist updated successfully.${RESET}"
    #     logger "mirrorlist" "[SUCCESS]: Mirrorlist updated successfully."
    # else
    #     echo -e "${RED}Failed to update mirrorlist.${RESET}"
    #     logger "mirrorlist" "[FAILED]: Failed to update mirrorlist."
    # fi

    # Step 3: Add Chaotic-AUR repository
    echo -e "${BLUE}Checking for Chaotic-AUR repository...${RESET}"
    logger "chaotic-aur" "[INFO]: Checking for Chaotic-AUR repository..."

    if is_chaotic_aur_installed; then
        echo -e "${YELLOW}Chaotic-AUR repository is already installed.${RESET}"
        logger "chaotic-aur" "[UPDATE]: Chaotic-AUR repository is already installed."
    else
        install_chaotic_aur
    fi
}
