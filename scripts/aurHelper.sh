#!/bin/bash

# Function to install paru or yay as AUR helper
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
