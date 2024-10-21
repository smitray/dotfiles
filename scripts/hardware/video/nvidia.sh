#!/bin/bash

# List of NVIDIA DKMS drivers for specific hardware generations
nvidia_dkms_drivers=(
    "nvidia-dkms"          # Supports modern NVIDIA GPUs, including your RTX 3050
    "nvidia-470xx-dkms"    # Legacy driver for some older GPUs (Turing, Volta, Pascal)
    "nvidia-390xx-dkms"    # Legacy driver for older GPUs (Fermi and some Kepler)
    "nvidia-340xx-dkms"    # Very old legacy driver for pre-Fermi GPUs
)

# Common packages for NVIDIA regardless of generation
common_packages=(
    "nvidia-utils"
    "nvidia-settings"
)

# Initialize an empty package list
package_list=()

# Detect NVIDIA GPU using lspci
gpu_info=$(lspci | grep -i "vga" | grep -i "nvidia")

# Check if an NVIDIA GPU is found
if [[ -n "$gpu_info" ]]; then
    echo "NVIDIA GPU detected: $gpu_info"
    logger "nvidiaDetect" "NVIDIA GPU detected: $gpu_info"
    
    # Add common packages to the package list
    package_list+=("${common_packages[@]}")

    # Determine the appropriate driver based on the detected hardware
    if echo "$gpu_info" | grep -q "RTX 30"; then
        echo "Your GPU is part of the Ampere series (RTX 30xx). Adding the appropriate driver."
        logger "nvidiaDetect" "GPU is Ampere (RTX 30xx). Adding nvidia-dkms."
        package_list+=("${nvidia_dkms_drivers[0]}")   # nvidia-dkms for modern GPUs
    elif echo "$gpu_info" | grep -q "Turing\|Volta\|Pascal"; then
        echo "Your GPU is part of the Turing, Volta, or Pascal series. Adding the appropriate driver."
        logger "nvidiaDetect" "GPU is Turing/Volta/Pascal. Adding nvidia-470xx-dkms."
        package_list+=("${nvidia_dkms_drivers[1]}")   # nvidia-470xx-dkms
    elif echo "$gpu_info" | grep -q "Fermi\|Kepler"; then
        echo "Your GPU is part of the Fermi or Kepler series. Adding the appropriate driver."
        logger "nvidiaDetect" "GPU is Fermi/Kepler. Adding nvidia-390xx-dkms."
        package_list+=("${nvidia_dkms_drivers[2]}")   # nvidia-390xx-dkms
    elif echo "$gpu_info" | grep -q "pre-Fermi"; then
        echo "Your GPU is from the pre-Fermi generation. Adding the appropriate driver."
        logger "nvidiaDetect" "GPU is pre-Fermi. Adding nvidia-340xx-dkms."
        package_list+=("${nvidia_dkms_drivers[3]}")   # nvidia-340xx-dkms
    else
        echo "Unable to determine the exact driver based on your GPU model. Please verify manually."
        logger "nvidiaDetect" "Unable to determine driver for GPU."
    fi

    # Output the package list to be installed
    echo "The following packages will be installed:"
    for pkg in "${package_list[@]}"; do
        echo "$pkg"
    done
    
    # Log the package list
    logger "nvidiaPackageList" "Packages to be installed: ${package_list[*]}"

    # Call the installPackages function with the package list
    installPackages "${package_list[@]}"

    # Step 1: Blacklist nouveau and configure modprobe for NVIDIA DRM
    echo "Configuring modprobe to blacklist nouveau and enable NVIDIA DRM..."
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOL
blacklist nouveau
options nvidia_drm modeset=1
EOL
    logger "nvidiaModprobe" "Blacklisted nouveau and enabled NVIDIA DRM."

    # Step 2: Modify mkinitcpio to include NVIDIA modules, without modifying hooks
    echo "Configuring mkinitcpio to include NVIDIA modules..."
    sudo sed -i '/^MODULES=/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf
    logger "nvidiaMkinitcpio" "Configured mkinitcpio to include NVIDIA modules."

    # Step 3: Rebuild initramfs
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
    if [[ $? -eq 0 ]]; then
        echo "Initramfs rebuilt successfully."
        logger "nvidiaInitramfs" "Initramfs rebuilt successfully."
    else
        echo "Failed to rebuild initramfs."
        logger "nvidiaInitramfs" "Failed to rebuild initramfs."
        exit 1
    fi

    # Step 4: Modify GRUB configuration
    echo "Configuring GRUB for NVIDIA DRM modeset..."
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia-drm.modeset=1 /' /etc/default/grub
    logger "nvidiaGRUB" "Configured GRUB for NVIDIA DRM modeset."

    # Step 5: Update GRUB
    echo "Updating GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    if [[ $? -eq 0 ]]; then
        echo "GRUB updated successfully."
        logger "nvidiaGRUB" "GRUB updated successfully."
    else
        echo "Failed to update GRUB."
        logger "nvidiaGRUB" "Failed to update GRUB."
        exit 1
    fi

    echo "NVIDIA setup completed successfully. Please reboot your system."
    logger "nvidiaSetup" "NVIDIA setup completed successfully."
    
else
    echo "No NVIDIA GPU detected on this system."
    logger "nvidiaDetect" "No NVIDIA GPU detected."
fi
