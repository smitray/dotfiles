#!/bin/bash
#List of all the global functions used in the scripts

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m' # Reset color

srcDir=$(dirname "$(realpath "$0")") || $srcDir
#Log management
logs="${srcDir}/logs"

# Define the AUR helper to use (paru or yay)
aurHlpr="${aurHlpr:-paru}"

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
}

# Function to run a script with colored output
runScript() {
  script_path="$1"

  if [ -f "$script_path" ]; then
    chmod +x "$script_path"

    echo -e "${CYAN}Running $script_path${RESET}"

    # shellcheck source=/dev/null
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

# Function to check if a package is already installed
pkg_installed() {
  pacman -Qq "$1" &>/dev/null
}

# Function to check if a package is available in the official pacman repositories
pkg_available_in_pacman() {
  pacman -Ss "$1" &>/dev/null
}

# Function to check if a package is available in AUR using the AUR helper (paru, yay, etc.)
pkg_available_in_aur() {
  "$aurHlpr" -Ss "$1" &>/dev/null
}

# Function to install collected packages from pacman and AUR
install_packages() {
  local archPkg=()
  local aurPkg=()

  # Collect packages
  for pkg in "$@"; do
    # Check if the package is already installed
    if pkg_installed "$pkg"; then
      echo -e "${GREEN}[skip] ${pkg} is already installed.${RESET}"
      logger "packageInstall" "[INFO]: ${pkg} is already installed."
    # Check if the package is available in pacman
    elif pkg_available_in_pacman "$pkg"; then
      echo -e "${CYAN}[pacman] Queueing ${pkg} for installation from official repo...${RESET}"
      archPkg+=("$pkg")
    # Check if the package is available in AUR
    elif pkg_available_in_aur "$pkg"; then
      echo -e "${CYAN}[AUR] Queueing ${pkg} for installation from AUR...${RESET}"
      aurPkg+=("$pkg")
    # If the package is not found in pacman or AUR
    else
      echo -e "${RED}Error: Package ${pkg} not found in pacman or AUR.${RESET}"
      logger "packageInstall" "[FAILED]: Package ${pkg} not found in pacman or AUR."
    fi
  done

  # Install packages from pacman
  if [[ ${#archPkg[@]} -gt 0 ]]; then
    echo -e "${BLUE}Installing packages from official Arch repo...${RESET}"
    if sudo pacman -S --noconfirm "${archPkg[@]}" 2>"${logs}/packageInstall.log"; then
      echo -e "${GREEN}Successfully installed ${archPkg[*]} from pacman.${RESET}"
      logger "packageInstall" "[SUCCESS]: Successfully installed ${archPkg[*]} from pacman."
    else
      echo -e "${RED}Error: Failed to install some packages from pacman.${RESET}"
    fi
  fi

  # Install packages from AUR
  if [[ ${#aurPkg[@]} -gt 0 ]]; then
    echo -e "${BLUE}Installing packages from AUR...${RESET}"
    if "$aurHlpr" -S --noconfirm "${aurPkg[@]}" 2>"${logs}/packageInstall.log"; then
      echo -e "${GREEN}Successfully installed ${aurPkg[*]} from AUR.${RESET}"
      logger "packageInstall" "[SUCCESS]: Successfully installed ${aurPkg[*]} from AUR."
    else
      echo -e "${RED}Error: Failed to install some packages from AUR.${RESET}"
    fi
  fi
}
