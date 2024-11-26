#!/bin/bash

clear

cat <<"EOF"

  ______          _       
 |  ____|        | |      
 | |__ ___  _ __ | |_ ___ 
 |  __/ _ \| '_ \| __/ __|
 | | | (_) | | | | |_\__ \
 |_|  \___/|_| |_|\__|___/
                          
                          
EOF

echo -e "${BLUE}[INFO]: Installing fonts...${RESET}"
logger "[INFO]:[Fonts Setup] Installing fonts"


# List of fonts
fonts=(
  # Nerd Fonts
  ttf-jetbrains-mono-nerd
  ttf-firacode-nerd
  ttf-hack-nerd
  ttf-cascadia-code-nerd
  ttf-ubuntu-mono-nerd
  ttf-iosevka-nerd

  # Language Support Fonts
  ttf-indic-otf
  noto-fonts
  noto-fonts-extra
  noto-fonts-cjk

  # Emoji Support
  noto-fonts-emoji

  # Additional Monospace Fonts
  ttf-dejavu
  ttf-liberation

  # AUR Fonts (add only if using an AUR helper like paru/yay)
  ttf-arabeyes-fonts  # Arabic
  ttf-arphic-ukai  # Chinese
  ttf-arphic-uming  # Chinese
  ttf-sazanami  # Japanese
  ttf-baekmuk  # Korean
)

# Install fonts
install_packages "${fonts[@]}"
