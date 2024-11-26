#!/bin/bash

clear

cat <<"EOF"
  _  __                 _           _____      _               
 | |/ /                | |         / ____|    | |              
 | ' / __ _ _ __   __ _| |_ __ _  | (___   ___| |_ _   _ _ __  
 |  < / _` | '_ \ / _` | __/ _` |  \___ \ / _ \ __| | | | '_ \ 
 | . \ (_| | | | | (_| | || (_| |  ____) |  __/ |_| |_| | |_) |
 |_|\_\__,_|_| |_|\__,_|\__\__,_| |_____/ \___|\__|\__,_| .__/ 
                                                        | |    
                                                        |_|    
EOF

echo -e "${BLUE}[INFO]: Installing Kanata and configuration for keyboard remap...${RESET}"
logger "[INFO]:[Kanata Setup] Installing Kanata and configuration for keyboard remap"

# Define the kanata packages, including all specified ones
kanata_packages=(
  "kanata"
)

# # Install kanata packages
install_packages "${kanata_packages[@]}"

if [[ ! -f "${HOME}/.config/kanata/config.kbd" ]]; then
  mkdir -p "${HOME}/.config/kanata"
  cp "${srcDir}/config/kanata/config.kbd" "${HOME}/.config/kanata/config.kbd"
  logger "[INFO]:[Kanata Setup] Copied config.kbd to ${HOME}/.config/kanata."
  echo -e "${GREEN}[INFO]: Copied config.kbd to ${HOME}/.config/kanata.${RESET}"
else
  logger "[INFO]:[Kanata Setup] config.kbd already exists in ${HOME}/.config/kanata."
  echo -e "${GREEN}[INFO]: config.kbd already exists in ${HOME}/.config/kanata.${RESET}"
fi

if [[ ! -f "${HOME}/.config/systemd/user/kanata.service" ]]; then

  if [[ ! -d "${HOME}/.config/systemd/user" ]]; then
    mkdir -p "${HOME}/.config/systemd/user"
    logger "[INFO]:[Kanata Setup] Created ${HOME}/.config/systemd/user."
    echo -e "${GREEN}[INFO]: Created ${HOME}/.config/systemd/user.${RESET}"
  fi

  cp "${srcDir}/config/kanata/kanata.service" "${HOME}/.config/systemd/user/kanata.service"
  logger "[INFO]:[Kanata Setup] Copied kanata.service to ${HOME}/.config/systemd/user."
  echo -e "${GREEN}[INFO]: Copied kanata.service to ${HOME}/.config/systemd/user.${RESET}"
else
  logger "[INFO]:[Kanata Setup] kanata.service already exists in ${HOME}/.config/systemd/user."
  echo -e "${GREEN}[INFO]: kanata.service already exists in ${HOME}/.config/systemd/user.${RESET}"
fi

if [[ ! -f "/etc/udev/rules.d/99-input.rules" ]]; then
  sudo cp "${srcDir}/config/kanata/99-input.rules" "/etc/udev/rules.d/99-input.rules"
  logger "[INFO]:[Kanata Setup] Copied 99-input.rules to /etc/udev/rules.d."
  echo -e "${GREEN}[INFO]: Copied 99-input.rules to /etc/udev/rules.d.${RESET}"
else
  logger "[INFO]:[Kanata Setup] 99-input.rules already exists in /etc/udev/rules.d."
  echo -e "${GREEN}[INFO]: 99-input.rules already exists in /etc/udev/rules.d.${RESET}"
fi

# Check if uinput exists in group else add it
if ! grep -q uinput /etc/group; then
  sudo groupadd uinput
  sudo usermod -aG input "${USER}"
  sudo usermod -aG uinput "${USER}"
  logger "[INFO]:[Kanata Setup] Added uinput group and added ${USER} to input and uinput groups."
  echo -e "${GREEN}[INFO]: Added uinput group and added ${USER} to input and uinput groups.${RESET}"

  sudo udevadm control --reload && udevadm trigger --verbose --sysname-match=uniput
  sudo modprobe uinput

  systemctl --user enable kanata.service
  systemctl --user start kanata.service

  logger "[INFO]:[Kanata Setup] Enabled and started kanata.service."
  echo -e "${GREEN}[INFO]: Enabled and started kanata.service.${RESET}"
else
  logger "[INFO]:[Kanata Setup] uinput group already exists."
  echo -e "${GREEN}[INFO]: uinput group already exists.${RESET}"
fi
