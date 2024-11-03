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

# Define the AUR helper to use (paru or yay)
aurHlpr="${aurHlpr:-paru}"

#Log management
logs="${srcDir}/script.log"

# Check if the log file exists
if [[ -f "$logs" ]]; then
  echo -e "${YELLOW}Log file found. Removing old log file...${RESET}"

  # Remove the existing log file
  if rm "$logs"; then
    echo -e "${GREEN}Old log file removed successfully.${RESET}"
  else
    echo -e "${RED}Error: Failed to remove the log file: $logs${RESET}"
    exit 1
  fi
fi

# Create a new log file
echo -e "${YELLOW}Creating a new log file...${RESET}"
if touch "$logs"; then
  echo -e "${GREEN}Log file created successfully: $logs${RESET}"
else
  echo -e "${RED}Error: Failed to create the log file: $logs${RESET}"
  exit 1
fi

logger() {
  local logMsg="${1}"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $logMsg" >>"$logs"
}

# Function to run a script with colored output
runScript() {
  local script_path="$1"

  # Check if the script file exists
  if [[ -f "$script_path" ]]; then

    # Ensure the script is executable
    if [[ ! -x "$script_path" ]]; then
      chmod +x "$script_path"
      echo -e "${YELLOW}${script_path} was not executable. Made it executable.${RESET}"
    fi

    echo -e "${CYAN}Running $script_path...${RESET}"

    # Try to source the script
    # shellcheck source=/dev/null
    if source "$script_path"; then
      echo -e "${GREEN}Success: $script_path sourced successfully.${RESET}"
      logger "[SUCCESS]:[Script Source] Successfully sourced $script_path"
    else
      echo -e "${RED}Error: Failed to source $script_path.${RESET}"
      logger "[FAILED]:[Script Source] Failed to source $script_path"
      exit 1
    fi
  else
    # File not found error handling
    echo -e "${RED}Error: $script_path not found.${RESET}"
    logger "[FAILED]:[Script Source] $script_path not found"
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
      logger "[INFO]:[Package Install] ${pkg} is already installed."
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
      logger "[FAILED]:[Package Install] Package ${pkg} not found in pacman or AUR."
    fi
  done

  # # Install packages from pacman
  # if [[ ${#archPkg[@]} -gt 0 ]]; then
  #   echo -e "${BLUE}Installing packages from official Arch repo...${RESET}"
  #   if sudo pacman -S --noconfirm "${archPkg[@]}" 2>"${logs}"; then
  #     echo -e "${GREEN}Successfully installed ${archPkg[*]} from pacman.${RESET}"
  #     logger "[SUCCESS]:[Package Install] Successfully installed ${archPkg[*]} from pacman."
  #   else
  #     echo -e "${RED}Error: Failed to install some packages from pacman.${RESET}"
  #   fi
  # fi

  # # Install packages from AUR
  # if [[ ${#aurPkg[@]} -gt 0 ]]; then
  #   echo -e "${BLUE}Installing packages from AUR...${RESET}"
  #   if "$aurHlpr" -S --noconfirm "${aurPkg[@]}" 2>"${logs}"; then
  #     echo -e "${GREEN}Successfully installed ${aurPkg[*]} from AUR.${RESET}"
  #     logger "[SUCCESS]:[Package Install] Successfully installed ${aurPkg[*]} from AUR."
  #   else
  #     echo -e "${RED}Error: Failed to install some packages from AUR.${RESET}"
  #   fi
  # fi
}
