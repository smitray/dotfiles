#!/bin/bash

clear

cat <<"EOF"

                       _    _      _                 
     /\               | |  | |    | |                
    /  \  _   _ _ __  | |__| | ___| |_ __   ___ _ __ 
   / /\ \| | | | '__| |  __  |/ _ \ | '_ \ / _ \ '__|
  / ____ \ |_| | |    | |  | |  __/ | |_) |  __/ |   
 /_/    \_\__,_|_|    |_|  |_|\___|_| .__/ \___|_|   
                                    | |              
                                    |_|              

EOF


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
    git clone "https://aur.archlinux.org/$aurHlpr.git"
    cd "$aurHlpr" || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf "$aurHlpr"

    # Confirm installation
    if command -v "$aurHlpr" &>/dev/null; then
      echo -e "${GREEN}$aurHlpr installed successfully!${RESET}"
      logger "[INFO]:[AUR] $aurHlpr installed successfully."
    else
      echo -e "${RED}Failed to install $aurHlpr. Please check the installation steps.${RESET}"
      logger "[FAILED]:[AUR] Failed to install $aurHlpr."
      exit 1
    fi
  else
    echo -e "${GREEN}$aurHlpr is already installed!${RESET}"
    logger "[INFO]:[AUR] $aurHlpr is already installed."
  fi
}

# Ensure the AUR helper is available globally for other scripts
install_aur_helper
export aurHlpr
# sleep 1
