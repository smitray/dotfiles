#!/bin/bash

#Actual path of the script
srcDir=$(dirname "$(realpath "$0")")
export srcDir

# clear the screen
clear

echo -e "${BLUE} Welcome to Arch Linux Post Install Script${RESET}"
echo -e "${CYAN} Script started at $(date)${RESET}"
echo -e "${YELLOW} Running as $(whoami)${RESET}"

# ASCII art without color (you can colorize this too if needed)
cat <<"EOF"

  ___           _               _   _                  _                 _ 
 / _ \         | |        _    | | | |                | |               | |
/ /_\ \_ __ ___| |__    _| |_  | |_| |_   _ _ __  _ __| | __ _ _ __   __| |
|  _  | '__/ __| '_ \  |_   _| |  _  | | | | '_ \| '__| |/ _` | '_ \ / _` |
| | | | | | (__| | | |   |_|   | | | | |_| | |_) | |  | | (_| | | | | (_| |
\_| |_/_|  \___|_| |_|         \_| |_/\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
                                       __/ | |                             
                                      |___/|_|                             

EOF

# Check if globalFn.sh is available and executable, otherwise make it executable and source it
if [[ -f "${srcDir}/scripts/globalFn.sh" ]]; then

  # Ensure the script is executable, make it executable if it isn't
  if [[ ! -x "${srcDir}/scripts/globalFn.sh" ]]; then
    chmod +x "${srcDir}/scripts/globalFn.sh"
    echo -e "${YELLOW}${srcDir}/scripts/globalFn.sh was not executable. Made it executable.${RESET}"
  fi

  # Try to source the script
  if source "${srcDir}/scripts/globalFn.sh"; then
    echo -e "${GREEN}${srcDir}/scripts/globalFn.sh found and sourced successfully.${RESET}"
  else
    echo -e "${RED}Error: ${srcDir}/scripts/globalFn.sh could not be sourced.${RESET}"
    exit 1
  fi

else
  # Log and exit if the script is not found
  echo -e "${RED}${srcDir}/scripts/globalFn.sh not found.${RESET}"
  logger "global" "[FAILED]: ${srcDir}/scripts/globalFn.sh not found."
  exit 1
fi


# Check and make sure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Error: This script should not be run as root. Please run as a regular user.${RESET}"
  exit 1
else
  echo -e "${GREEN}Success: You are not running as root. Continuing...${RESET}"
fi

#Add the aurHelper.sh script
# runScript "${srcDir}/scripts/aurHelper.sh"
# Add the base.sh script
# runScript "${srcDir}/scripts/base.sh"
Add nvidia.sh script
runScript "${srcDir}/scripts/nvidia.sh"
