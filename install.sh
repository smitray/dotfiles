#!/bin/bash

#Actual path of the script
srcDir=$(dirname "$(realpath "$0")")

# Check if globalFn.sh is available and executable, otherwise make it executable and source it
if [ -f "${srcDir}/scripts/globalFn.sh" ]; then
    if [ ! -x "${srcDir}/scripts/globalFn.sh" ]; then
        # Make the script executable if it isn't already
        chmod +x "${srcDir}/scripts/globalFn.sh"
        echo -e "${YELLOW} ${srcDir}/scripts/globalFn.sh was not executable. Made it executable.${RESET}"
    fi

    # Source the script
    source "${srcDir}/scripts/globalFn.sh"
    echo -e "${GREEN}${srcDir}/scripts/globalFn.sh found and sourced successfully.${RESET}"

    # Add logs to the log file
    logger "global" "[Success]: ${srcDir}/scripts/globalFn.sh found and sourced successfully."
else
    echo -e "${RED}${srcDir}/scripts/globalFn.sh not found.${RESET}"
    logger "global" "[FAILED]: ${srcDir}/scripts/globalFn.sh not found$."
    exit 1
fi

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

# Check and make sure the script is not run as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: This script should not be run as root. Please run as a regular user.${RESET}"
    exit 1
else
    echo -e "${GREEN}Success: You are not running as root. Continuing...${RESET}"
fi

#Add the aurHelper.sh script
runScript "${srcDir}/scripts/aurHelper.sh"
#Add the base.sh script
runScript "${srcDir}/scripts/base.sh"
setup_base
#Add nvidia.sh script
runScript "${srcDir}/scripts/nvidia.sh"

