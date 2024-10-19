#!/bin/bash
#List of all the global functions used in the scripts

#Write a function to check whether the sub-script is available or not
#If the script is available then make it executable and execute it

function runScript() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        echo -e "${INFO} Running $1"
        source "$1"
    else
        echo -e "${ERROR} $1 not found" | tee -a "${logs}/00-globalFn-$(date +"%Y%m%d-%H%M%S").log"
        exit 1
    fi
}