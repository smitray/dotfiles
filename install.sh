#!/bin/bash

# We will write Arch linux post install script here
# This script will install all the necessary packages and configure the system
# There will be sub-scripts for each tasks global functions, installing nvidia drivers etc.
# all the sub scripts will be called from this script and all sub scripts are in scripts folder.
# Log is mandatory for each script and it will be stored in logs folder and will be named with date time
# since this is the initial script, we will start with the basic requirements.


# Declare all color codes like warning, error, success etc to echo messages in color
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
WARNING="$(tput setaf 3)[WARNING]$(tput sgr0)"
INFO="$(tput setaf 6)[INFO]$(tput sgr0)"
SUCCESS="$(tput setaf 2)[SUCCESS]$(tput sgr0)"

#Print the welcome message with the script name, date and time and with a ARCH linux acsii art
echo -e "${INFO} Welcome to Arch Linux Post Install Script"
echo -e "${INFO} Script started at $(date)"
echo -e "${INFO} Running as $(whoami)"
cat << "EOF"

  ___           _               _   _                  _                 _ 
 / _ \         | |        _    | | | |                | |               | |
/ /_\ \_ __ ___| |__    _| |_  | |_| |_   _ _ __  _ __| | __ _ _ __   __| |
|  _  | '__/ __| '_ \  |_   _| |  _  | | | | '_ \| '__| |/ _` | '_ \ / _` |
| | | | | | (__| | | |   |_|   | | | | |_| | |_) | |  | | (_| | | | | (_| |
\_| |_/_|  \___|_| |_|         \_| |_/\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
                                       __/ | |                             
                                      |___/|_|                             

EOF


#Check and make sure the script should not run as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${ERROR} This script should not be run as root"
    exit 1
fi

#Create a logs folder if it does not exist
mkdir -p logs


# import all the global functions
srcDir=$(dirname "$(realpath "$0")")
#define logs folder path as logs from srcDir
logs="$srcDir/logs"
#if log files exists then remove them, *.log
if [ -f "${logs}/*.log" ]; then
    rm -f "${logs}/*.log"
fi

#check file globalFn.sh is available and executable, if yes then source it, else
#if available then make it executable and source it or exit
if [ -f "${srcDir}/scripts/globalFn.sh" ]; then
    chmod +x "${srcDir}/scripts/globalFn.sh"
    source "${srcDir}/scripts/globalFn.sh"
    #add logs to the log file
    echo -e "${SUCCESS} ${srcDir}/scripts/globalFn.sh found and sourced" | tee -a "${logs}/00-globalFn-base-$(date +"%Y%m%d-%H%M%S").log"
else
    echo -e "${ERROR} ${srcDir}/scripts/globalFn.sh not found" | tee -a "${logs}/00-globalFn-base-$(date +"%Y%m%d-%H%M%S").log"
    exit 1
fi

#Check if reflector is installed and then update the mirrorlist for India
if ! pacman -Qq reflector &>/dev/null; then
    echo -e "${WARNING} reflector is not installed. Installing reflector"
    runScript "${srcDir}/scripts/pkgSrcUpdate.sh"
else
    echo -e "${SUCCESS} reflector is already installed"
fi

# Check if base-devel is installed, if not source scripts/base.sh. Please check the script is available before sourcing
if ! pacman -Qq base-devel &>/dev/null; then
    echo -e "${WARNING} base-devel is not installed. Installing base-devel"
    runScript "${srcDir}/scripts/base.sh"
else
    echo -e "${SUCCESS} base-devel is already installed"
fi

