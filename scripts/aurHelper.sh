#!/bin/bash

# This script provides a function to install an AUR helper (either paru or yay).
# It prompts the user to select their preferred AUR helper and installs it if it is not already installed.
#
# Usage:
#   1. Run the script.
#   2. Follow the prompt to select your preferred AUR helper (1 for paru, 2 for yay).
#
# The script performs the following steps:
#   1. Prompts the user to select an AUR helper.
#   2. Checks if the selected AUR helper is already installed.
#   3. If not installed, clones the respective AUR repository and installs the AUR helper.
#   4. Confirms the installation and provides feedback to the user.
#
# Note:
#   - The script uses git and makepkg for installation, so ensure these tools are available on your system.
#   - The script assumes it is run in an environment where sudo privileges are available for package installation.
install_aur_helper() {
  echo -e "${BLUE}Select your preferred AUR helper:${RESET}"
  echo -e "${YELLOW}1. paru${RESET}"
  echo -e "${YELLOW}2. yay${RESET}"
  read -rp "Enter the number for the AUR helper you want to install (1 for paru, 2 for yay): " choice

  case $choice in
  1)
    aurHlpr="paru"
    ;;
  2)
    aurHlpr="yay"
    ;;
  *)
    echo -e "${RED}Invalid choice. Please select 1 or 2.${RESET}"
    exit 1
    ;;
  esac

  # Check if the selected AUR helper is already installed
  if ! command -v "$aurHlpr" &>/dev/null; then
    echo -e "${CYAN}Installing $aurHlpr...${RESET}"

    # Install the selected AUR helper
    if [ "$aurHlpr" == "paru" ]; then
      git clone https://aur.archlinux.org/paru.git
      cd paru || exit
      makepkg -si --noconfirm
      cd ..
      rm -rf paru
    elif [ "$aurHlpr" == "yay" ]; then
      git clone https://aur.archlinux.org/yay.git
      cd yay || exit
      makepkg -si --noconfirm
      cd ..
      rm -rf yay
    fi

    # Confirm installation
    if command -v "$aurHlpr" &>/dev/null; then
      echo -e "${GREEN}$aurHlpr installed successfully!${RESET}"
    else
      echo -e "${RED}Failed to install $aurHlpr. Please check the installation steps.${RESET}"
      exit 1
    fi
  else
    echo -e "${GREEN}$aurHlpr is already installed!${RESET}"
  fi
}

# Ensure the AUR helper is available globally for other scripts
install_aur_helper
export aurHlpr
