#!/bin/bash

clear

cat <<"EOF"

                    _ _          _____      _               
     /\            | (_)        / ____|    | |              
    /  \  _   _  __| |_  ___   | (___   ___| |_ _   _ _ __  
   / /\ \| | | |/ _` | |/ _ \   \___ \ / _ \ __| | | | '_ \ 
  / ____ \ |_| | (_| | | (_) |  ____) |  __/ |_| |_| | |_) |
 /_/    \_\__,_|\__,_|_|\___/  |_____/ \___|\__|\__,_| .__/ 
                                                     | |    
                                                     |_|    

EOF

echo -e "${BLUE}[INFO]: Installing PipeWire audio packages and EasyEffects...${RESET}"
log "[INFO]: Installing PipeWire audio packages and EasyEffects..."

# Define the audio packages, including all specified ones
audio_packages=(
  "pipewire"            # Core PipeWire package
  "pipewire-alsa"       # PipeWire ALSA client
  "pipewire-audio"      # PipeWire audio client
  "pipewire-jack"       # PipeWire JACK client
  "pipewire-pulse"      # PipeWire PulseAudio client
  "gst-plugin-pipewire" # PipeWire GStreamer client
  "wireplumber"         # PipeWire session manager
  "pavucontrol"         # PulseAudio volume control
  "pamixer"             # CLI volume control for PulseAudio
  "easyeffects"         # EasyEffects for advanced audio effects
)

# Echo the audio packages to be installed
echo -e "${YELLOW}[INFO]: Installing the following audio packages: ${audio_packages[*]} ${RESET}"

# Install audio packages
install_packages "${audio_packages[@]}"

echo -e "${GREEN}[SUCCESS]: Audio setup complete with PipeWire, EasyEffects, and related packages.${RESET}"
logger "[SUCCESS]:[AUDIO] Audio setup complete with PipeWire, EasyEffects, and related packages."
