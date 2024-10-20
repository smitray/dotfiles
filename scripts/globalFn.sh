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
        echo -e "${GREEN}Log file created: ${CYAN}$logFile${RESET}"
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
            logger "runScript" "${GREEN}Successfully sourced $script_path${RESET}"
            echo -e "${GREEN}Success: $script_path sourced successfully.${RESET}"
        else
            logger "runScript" "${RED}Failed to source $script_path${RESET}"
            echo -e "${RED}Error: Failed to source $script_path${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Error: $script_path not found${RESET}"
        logger "runScript" "${RED}$script_path not found${RESET}"
        exit 1
    fi
}

#Write a function to install packages with following conditions:
#Input is a list of packages
#check if the package is already installed
#If not installed then check whether the package is available in pacman or aur or chaotic-aur
#If available then install the package and log the output of the installation
#If not available then log the error message

installPackages() {
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
