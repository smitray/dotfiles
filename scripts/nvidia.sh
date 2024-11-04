#!/bin/bash

clear

cat <<"EOF"

  _   _       _     _ _          _____      _               
 | \ | |     (_)   | (_)        / ____|    | |              
 |  \| |_   ___  __| |_  __ _  | (___   ___| |_ _   _ _ __  
 | . ` \ \ / / |/ _` | |/ _` |  \___ \ / _ \ __| | | | '_ \ 
 | |\  |\ V /| | (_| | | (_| |  ____) |  __/ |_| |_| | |_) |
 |_| \_| \_/ |_|\__,_|_|\__,_| |_____/ \___|\__|\__,_| .__/ 
                                                     | |    
                                                     |_|    

EOF

# List of NVIDIA DKMS drivers for specific hardware generations
nvidia_dkms_drivers=(
  nvidia-dkms       # Supports modern NVIDIA GPUs, including your RTX 3050
  nvidia-470xx-dkms # Legacy driver for some older GPUs (Turing, Volta, Pascal)
  nvidia-390xx-dkms # Legacy driver for older GPUs (Fermi and some Kepler)
  nvidia-340xx-dkms # Very old legacy driver for pre-Fermi GPUs
)

# Common packages for NVIDIA regardless of generation
package_list=(
  nvidia-utils
  nvidia-settings
  libva
  libva-nvidia-driver-git
)

# Initite the log file
logs="${logs:-$srcDir/script.log}"
logger "[INFO]:[NVIDIA] NVIDIA script started..."

# Function to choose the correct driver based on the GPU detected
get_nvidia_driver() {
  local gpu_info="$1"

  if echo "$gpu_info" | grep -q "RTX 30"; then
    echo "${nvidia_dkms_drivers[0]}" # nvidia-dkms
  elif echo "$gpu_info" | grep -q "Turing\|Volta\|Pascal"; then
    echo "${nvidia_dkms_drivers[1]}" # nvidia-470xx-dkms
  elif echo "$gpu_info" | grep -q "Fermi\|Kepler"; then
    echo "${nvidia_dkms_drivers[2]}" # nvidia-390xx-dkms
  elif echo "$gpu_info" | grep -q "pre-Fermi"; then
    echo "${nvidia_dkms_drivers[3]}" # nvidia-340xx-dkms
  else
    return 1 # Unable to determine driver
  fi
}

# Detect the GPU generation and store it in a variable
gpu_info=$(lspci -v | grep -A 12 VGA | grep -i nvidia)

if [[ -n "$gpu_info" ]]; then
  echo -e "${GREEN}NVIDIA GPU detected: $gpu_info${RESET}"
  logger "[INFO]:[NVIDIA] NVIDIA GPU detected: $gpu_info"

  # Get the appropriate NVIDIA driver
  if nvidia_driver=$(get_nvidia_driver "$gpu_info"); then
    echo -e "${GREEN}Adding NVIDIA driver: $nvidia_driver${RESET}"
    logger "[INFO]:[NVIDIA] Adding NVIDIA driver: $nvidia_driver"
    package_list+=("$nvidia_driver")
  else
    echo -e "${RED}Unable to determine the exact driver for your GPU. Please verify manually.${RESET}"
    logger "[FAILED]:[NVIDIA] Unable to determine driver for GPU."
    return 1
  fi

  # Add the kernel headers to the package list
  for pkgbase_file in /usr/lib/modules/*/pkgbase; do
    if [[ -f "$pkgbase_file" ]]; then
      while IFS= read -r krnl; do
        package_list+=("${krnl}-headers")
      done <"$pkgbase_file"
    fi
  done

  # Display and install the packages
  echo -e "${BLUE}The following packages will be installed: ${package_list[*]}${RESET}"
  if install_packages "${package_list[@]}"; then
    echo -e "${GREEN}All NVIDIA packages installed successfully.${RESET}"
    logger "[SUCCESS]: All NVIDIA packages installed successfully."
  else
    echo -e "${RED}Failed to install NVIDIA packages.${RESET}"
    logger "[FAILED]: Failed to install NVIDIA packages."
    return 1
  fi

  # Update mkinitcpio
  if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
    echo "Nvidia modules already included in /etc/mkinitcpio.conf" | tee -a "$logs"
  else
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    echo "Nvidia modules added in /etc/mkinitcpio.conf" | tee -a "$logs"
  fi

  sudo mkinitcpio -P | tee -a "$logs"

  # Configure modprobe for NVIDIA DRM
  modprobe_conf="/etc/modprobe.d/nvidia.conf"

  if [ -f "$modprobe_conf" ]; then
    echo "Nvidia DRM modeset=1 is already set in $modprobe_conf" | tee -a "$logs"
  else
    echo -e "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$modprobe_conf" | tee -a "$logs"
    echo "Nvidia DRM modeset=1 added to $modprobe_conf" | tee -a "$logs"
  fi

  # Update the bootloader
  if [ -f /etc/default/grub ]; then
    if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
      sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
      echo "nvidia-drm.modeset=1 added to /etc/default/grub" | tee -a "$logs"
    fi

    if ! grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
      sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
      echo "nvidia_drm.fbdev=1 added to /etc/default/grub" | tee -a "$logs"
    fi

    # Regenerate GRUB configuration if any changes were made
    if sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub || sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
      sudo grub-mkconfig -o /boot/grub/grub.cfg | tee -a "$logs"
    fi
  else
    echo "/etc/default/grub does not exist" | tee -a "$logs"
  fi

  # Blacklist the nouveau driver
  blacklist_conf="/etc/modprobe.d/nouveau.conf"
  blacklist_cmd="/etc/modprobe.d/blacklist.conf"

  if [ -f "$blacklist_conf" ]; then
    echo "Nouveau is already blacklisted" | tee -a "$logs"
  else
    echo "blacklist nouveau" | sudo tee "$blacklist_conf" | tee -a "$logs"
    echo "Nouveau blacklist added to $blacklist_conf" | tee -a "$logs"

    if [ -f "$blacklist_cmd" ]; then
      echo "install nouveau /bin/true" | sudo tee -a "$blacklist_cmd" | tee -a "$logs"
    else
      echo "install nouveau /bin/true" | sudo tee "$blacklist_cmd" | tee -a "$logs"
    fi
  fi

else
  echo -e "${YELLOW}NVIDIA GPU not detected.${RESET}"
  logger "[WARNING]:[NVIDIA] NVIDIA GPU not detected."
fi
