#!/bin/bash

# List of NVIDIA DKMS drivers for specific hardware generations
nvidia_dkms_drivers=(
  nvidia-dkms       # Supports modern NVIDIA GPUs, including your RTX 3050
  nvidia-470xx-dkms # Legacy driver for some older GPUs (Turing, Volta, Pascal)
  nvidia-390xx-dkms # Legacy driver for older GPUs (Fermi and some Kepler)
  nvidia-340xx-dkms # Very old legacy driver for pre-Fermi GPUs
)

# Common packages for NVIDIA regardless of generation
common_packages=(
  nvidia-utils
  nvidia-settings
  libva
  libva-nvidia-driver-git
)

# Initialize an empty package list
package_list=()

# Initialize an empty nvidia_pkg array
nvidia_pkg=()

# Detect NVIDIA GPU using lspci
gpu_info=$(lspci | grep -i "vga" | grep -i "nvidia")

# Check if an NVIDIA GPU is found
if [[ -n "$gpu_info" ]]; then
  echo -e "${GREEN}NVIDIA GPU detected: $gpu_info${RESET}"
  logger "nvidia" "[SUCCESS]: NVIDIA GPU detected: $gpu_info"

  # Add common packages to the package list
  package_list+=("${common_packages[@]}")

  # This script determines the appropriate NVIDIA driver to install based on the GPU model.
  # It checks the GPU information and matches it against known series (Ampere, Turing, Volta, Pascal, Fermi, Kepler, pre-Fermi).
  # Depending on the detected series, it adds the corresponding driver to the package list.
  #
  # - Ampere (RTX 30xx): Adds nvidia-dkms
  # - Turing, Volta, Pascal: Adds nvidia-470xx-dkms
  # - Fermi, Kepler: Adds nvidia-390xx-dkms
  # - pre-Fermi: Adds nvidia-340xx-dkms
  #
  # If the GPU model cannot be determined, it logs a message indicating manual verification is needed.
  if echo "$gpu_info" | grep -q "RTX 30"; then
    echo -e "${GREEN}Your GPU is part of the Ampere series (RTX 30xx). Adding the appropriate driver.${RESET}"
    logger "nvidia" "[SUCCESS]: GPU is Ampere (RTX 30xx). Adding nvidia-dkms."
    package_list+=("${nvidia_dkms_drivers[0]}") # nvidia-dkms for modern GPUs
  elif echo "$gpu_info" | grep -q "Turing\|Volta\|Pascal"; then
    echo -e "${GREEN}Your GPU is part of the Turing, Volta, or Pascal series. Adding the appropriate driver.${RESET}"
    logger "nvidia" "[SUCCESS]: GPU is Turing/Volta/Pascal. Adding nvidia-470xx-dkms."
    package_list+=("${nvidia_dkms_drivers[1]}") # nvidia-470xx-dkms
  elif echo "$gpu_info" | grep -q "Fermi\|Kepler"; then
    echo -e "${GREEN}Your GPU is part of the Fermi or Kepler series. Adding the appropriate driver.${RESET}"
    logger "nvidia" "[SUCCESS]: GPU is Fermi/Kepler. Adding nvidia-390xx-dkms."
    package_list+=("${nvidia_dkms_drivers[2]}") # nvidia-390xx-dkms
  elif echo "$gpu_info" | grep -q "pre-Fermi"; then
    echo -e "${GREEN}Your GPU is from the pre-Fermi generation. Adding the appropriate driver.${RESET}"
    logger "nvidia" "[SUCCESS]: GPU is pre-Fermi. Adding nvidia-340xx-dkms."
    package_list+=("${nvidia_dkms_drivers[3]}") # nvidia-340xx-dkms
  else
    echo -e "${RED} Unable to determine the exact driver based on your GPU model. Please verify manually.${RESET}"
    logger "nvidia" "[FAILED]: Unable to determine driver for GPU."
  fi

  # This script iterates through all pkgbase files in the /usr/lib/modules/*/pkgbase directory.
  # For each pkgbase file found, it reads the kernel version from the file.
  # It then constructs a list of NVIDIA-related packages by appending "-headers" to the kernel version
  # and adding any additional NVIDIA packages specified in the nvidia_pkg array.
  # Finally, it prints out the list of packages that will be installed.
  for pkgbase_file in /usr/lib/modules/*/pkgbase; do
    if [[ -f "$pkgbase_file" ]]; then
      while IFS= read -r krnl; do
        for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
          # Add the package to the list
          package_list+=("$NVIDIA")
        done
      done <"$pkgbase_file"
    fi
  done

  # This script installs NVIDIA packages and logs the process.
  # It performs the following steps:
  # 1. Prints the list of packages to be installed.
  # 2. Logs the list of packages to be installed.
  # 3. Calls the installPackages function to install the packages.
  # 4. Checks if the installation was successful:
  #    - If successful, prints and logs a success message.
  #    - If failed, prints and logs a failure message.
  echo -e "${BLUE}The following packages will be installed: ${package_list[*]}${RESET}"
  # if installPackages "${package_list[@]}"; then
  #   echo -e "${GREEN}All NVIDIA packages have been installed successfully.${RESET}"
  #   logger "packageInstall" "[SUCCESS]: All NVIDIA packages installed successfully: ${package_list[*]}"
  # else
  #   echo -e "${RED}Failed to install NVIDIA packages.${RESET}"
  #   logger "packageInstall" "[FAILED]: Failed to install NVIDIA packages."
  # fi

else
  echo -e "${YELLOW}No NVIDIA GPU detected on this system.${RESET}"
  logger "nvidia" "[INFO]: No NVIDIA GPU detected."
fi
