#!/bin/bash
#List of all the global functions used in the scripts

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m' # Reset color

#Log management
logs="${srcDir}/logs"

# Check if the logs folder exists
# Check if the logs folder exists
if [[ -d "$logs" ]]; then
    # Check if there are any log files in the folder
    if compgen -G "$logs/*.log" >/dev/null; then
        echo -e "${BLUE}Cleaning log files in $logs...${RESET}"
        # Remove all files with .log extension
        rm -f "$logs"/*.log
        echo -e "${GREEN}Log files removed successfully.${RESET}"
    else
        echo -e "${CYAN}No log files found in $logs. No cleanup needed.${RESET}"
    fi
else
    # Create the logs folder if it doesn't exist
    echo -e "${BLUE}$logs does not exist. Creating the logs folder.${RESET}"
    mkdir -p "$logs"
    echo -e "${GREEN}$logs folder created successfully.${RESET}"
fi

logger() {
    local logFile="${logs}/${1}.log"
    local logMsg="${2}"

    # Check if the file exists, if not, create it and log the action
    if [[ ! -f "$logFile" ]]; then
        echo -e "${YELLOW}Log file does not exist. Creating a new log file: ${CYAN}$logFile${RESET}"
        touch "$logFile"
        # echo -e "${GREEN}Log file created: ${CYAN}$logFile${RESET}"
    fi

    # Append the log content to the file with a timestamp
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $logMsg" >>"$logFile"
    # echo -e "${GREEN}Logged: ${CYAN}$logMsg${RESET} to ${CYAN}$logFile${RESET}"
}

# Function to run a script with colored output
runScript() {
    script_path="$1"

    if [ -f "$script_path" ]; then
        chmod +x "$script_path"

        echo -e "${CYAN}Running $script_path${RESET}"

        if source "$script_path"; then
            echo -e "${GREEN}Success: $script_path sourced successfully.${RESET}"
            logger "runScript" "[SUCCESS]: Successfully sourced $script_path${RESET}"
        else
            logger "runScript" "[FAILED]: to source $script_path${RESET}"
            echo -e "${RED}Error: Failed to source $script_path${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Error: $script_path not found${RESET}"
        logger "runScript" "[FAILED]: $script_path not found${RESET}"
        exit 1
    fi
}

# Function to install packages from either pacman or AUR
installPackages() {
    local pkgList=("$@")

    for pkg in "${pkgList[@]}"; do
        # Check if the package is already installed
        if ! pacman -Qq "$pkg" &>/dev/null; then
            echo -e "${BLUE}Installing $pkg...${RESET}"
            logger "packageInstall" "[INFO]: Installing $pkg..."

            # Check if the package is available in pacman
            if pacman -Ss "$pkg" &>/dev/null; then
                echo -e "${CYAN}Package $pkg found in pacman repository.${RESET}"
                logger "packageInstall" "[INFO]: Package $pkg found in pacman repository."
                sudo pacman -S --noconfirm "$pkg"
                echo -e "${GREEN}Successfully installed $pkg from pacman.${RESET}"
                logger "packageInstall" "[SUCCESS]: installed $pkg from pacman."

            # Check if the package is available in AUR via aurHlpr (e.g., paru or yay)
            elif "$aurHlpr" -Ss "$pkg" &>/dev/null; then
                echo -e "${CYAN}Package $pkg found in AUR.${RESET}"
                logger "packageInstall" "[INFO]: Package $pkg found in AUR."
                "$aurHlpr" -S --noconfirm "$pkg"
                echo -e "${GREEN}Successfully installed $pkg from AUR.${RESET}"
                logger "packageInstall" "[SUCCESS]: installed $pkg from AUR."

            # If the package is not found in pacman or AUR
            else
                echo -e "${RED}Error: Package $pkg not found in pacman or AUR.${RESET}"
                logger "packageInstall" "[FAILED]: Package $pkg not found in pacman or AUR."
            fi
        else
            echo -e "${GREEN}$pkg is already installed.${RESET}"
            logger "packageInstall" "[SUCCESS]: is already installed."
        fi
    done
}
