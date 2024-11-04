#!/bin/bash

clear

cat <<"EOF"

  ____  _            _              _   _        _____      _               
 |  _ \| |          | |            | | | |      / ____|    | |              
 | |_) | |_   _  ___| |_ ___   ___ | |_| |__   | (___   ___| |_ _   _ _ __  
 |  _ <| | | | |/ _ \ __/ _ \ / _ \| __| '_ \   \___ \ / _ \ __| | | | '_ \ 
 | |_) | | |_| |  __/ || (_) | (_) | |_| | | |  ____) |  __/ |_| |_| | |_) |
 |____/|_|\__,_|\___|\__\___/ \___/ \__|_| |_| |_____/ \___|\__|\__,_| .__/ 
                                                                     | |    
                                                                     |_|    

EOF

echo -e "${BLUE}[INFO]: Installing Bluetooth drivers and applying configuration...${RESET}"
logger "[INFO]:[Bluetooth] Installing Bluetooth drivers and applying configuration..."

# Define Bluetooth packages for PipeWire
bluetooth_packages=(
  "bluez"
  "bluez-utils"
  "blueman" # Optional graphical Bluetooth manager
)

# Install Bluetooth packages
install_packages "${bluetooth_packages[@]}"

# Ensure Bluetooth and NVIDIA modules are loaded in the correct order in mkinitcpio.conf
echo -e "${BLUE}[INFO]: Configuring mkinitcpio to include Bluetooth and NVIDIA modules...${RESET}"
logger "[INFO]:[Bluetooth] Configuring mkinitcpio to include Bluetooth and NVIDIA modules..."

if grep -q '^MODULES=.*nvidia' /etc/mkinitcpio.conf; then
  # Insert 'btusb' before 'nvidia' without duplication
  sudo sed -i '/^MODULES=/ s/nvidia/btusb nvidia/' /etc/mkinitcpio.conf
elif ! grep -q '^MODULES=.*btusb' /etc/mkinitcpio.conf; then
  # Add 'btusb nvidia' if neither module is listed
  sudo sed -i '/^MODULES=/ s/)/ btusb nvidia)/' /etc/mkinitcpio.conf
fi
sudo mkinitcpio -P

# Disable USB autosuspend for Bluetooth devices
echo -e "${BLUE}[INFO]: Disabling USB autosuspend for Bluetooth devices...${RESET}"
logger "[INFO]:[Bluetooth] Disabling USB autosuspend for Bluetooth devices..."
echo 'options usbcore autosuspend=-1' | sudo tee /etc/modprobe.d/usb.conf >/dev/null

# Set LDAC as preferred codec in BlueZ configuration
echo -e "${BLUE}[INFO]: Configuring Bluetooth to use LDAC codec...${RESET}"
logger "[INFO]:[Bluetooth] Configuring Bluetooth to use LDAC codec..."
sudo mkdir -p /etc/bluetooth
sudo tee /etc/bluetooth/main.conf >/dev/null <<EOF
[General]
Enable=Source,Sink,Media,Socket
EOF

# Create a systemd service to delay Bluetooth startup
echo -e "${BLUE}[INFO]: Creating systemd service to delay Bluetooth startup for stability...${RESET}"
logger "[INFO]:[Bluetooth] Creating systemd service to delay Bluetooth startup for stability..."
sudo tee /etc/systemd/system/bluetooth-restart.service >/dev/null <<EOF
[Unit]
Description=Restart Bluetooth service after boot
After=multi-user.target

[Service]
ExecStart=/bin/bash -c 'sleep 5; systemctl restart bluetooth.service'

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Bluetooth restart service
sudo systemctl enable bluetooth-restart.service
sudo systemctl daemon-reload
sudo systemctl restart bluetooth.service

echo -e "${GREEN}[SUCCESS]: Bluetooth setup complete with additional configurations for stability.${RESET}"
logger "[SUCCESS]:[Bluetooth] Bluetooth setup complete with additional configurations for stability."
