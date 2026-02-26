#!/bin/bash

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        echo "Please do not run this script as root"
        exit 1
    fi
}

# Check prerequisites
check_root

# Display ASCII art with effects
PYTHONPATH=~/script/src/tte python -m terminaltexteffects beams << "EOF"
-----------------------------------------------------------------------
 ██░ ██▓██   ██▓ ██▓███   ██▀███   ▄████▄   ██▀███   █    ██ ▒██   ██▒
▓██░ ██▒▒██  ██▒▓██░  ██▒▓██ ▒ ██▒▒██▀ ▀█  ▓██ ▒ ██▒ ██  ▓██▒▒▒ █ █ ▒░
▒██▀▀██░ ▒██ ██░▓██░ ██▓▒▓██ ░▄█ ▒▒▓█    ▄ ▓██ ░▄█ ▒▓██  ▒██░░░  █   ░
░▓█ ░██  ░ ▐██▓░▒██▄█▓▒ ▒▒██▀▀█▄  ▒▓▓▄ ▄██▒▒██▀▀█▄  ▓▓█  ░██░ ░ █ █ ▒
░▓█▒░██▓ ░ ██▒▓░▒██▒ ░  ░░██▓ ▒██▒▒ ▓███▀ ░░██▓ ▒██▒▒▒█████▓ ▒██▒ ▒██▒
 ▒ ░░▒░▒  ██▒▒▒ ▒▓▒░ ░  ░░ ▒▓ ░▒▓░░ ░▒ ▒  ░░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ▒▒ ░ ░▓ ░
 ▒ ░▒░ ░▓██ ░▒░ ░▒ ░       ░▒ ░ ▒░  ░  ▒     ░▒ ░ ▒░░░▒░ ░ ░ ░░   ░▒ ░
 ░  ░░ ░▒ ▒ ░░  ░░         ░░   ░ ░          ░░   ░  ░░░ ░ ░  ░    ░
 ░  ░  ░░ ░                 ░     ░ ░         ░        ░      ░    ░
        ░ ░                       ░
                           The Future Is Now
                             ©xSghetti 2026
-----------------------------------------------------------------------
EOF

echo ":: WARNING! This script is meant for Nvidia users only! It installs the nvidia-dkms and nvidia-utils packages"

read -p "Do you want to continue? (Y/n) " answer

# Set default to Yes if empty
if [[ -z "$answer" ]]; then
    answer="Y"
fi

case $answer in
    [Yy]* )
      echo ":: Install Continuing..."
      
      #Copy mkinitcpio.conf
      echo ":: Configuring mkinitcpio..."
      sudo cp -r ~/script/src/mkinitcpio.conf /etc/mkinitcpio.conf
        
      #Make /etc/modprobe.d/nvidia.conf
      echo ":: Setting up NVIDIA modules..."
      sudo touch /etc/modprobe.d/nvidia.conf
      sudo cp -r ~/script/src/nvidia.conf /etc/modprobe.d/nvidia.conf
      
      sudo mkinitcpio -P
      
      #Download and Install Yay if not already present
      if ! command -v yay &>/dev/null; then
          echo ":: Installing Yay AUR helper..."
          sudo pacman -S --needed git base-devel
          git clone https://aur.archlinux.org/yay-bin.git
          cd yay-bin
          makepkg -si
      else
          echo ":: Yay already installed, skipping..."
      fi
      
      #Download and Install packages
      echo ":: Installing packages..."
      yay -S --needed --noconfirm - < ~/script/src/yay.txt
      
      #Clones Hyprcrux Repo and copies them to their correct locations.
      echo ":: Cloning Hyprcrux configuration..."
      cd ~/script/
      ./clone.sh
      
      echo ":: Restoring ZSH"
      ~/script/zsh.sh
      
      echo ":: Installing Grub Theme"
      ~/script/grub.sh
      ~/script/greetd.sh
      
      sudo systemctl enable bluetooth && sudo systemctl start bluetooth
      sudo systemctl enable greetd && sudo systemctl start greetd

      echo ":: Installation complete!"
      read -p ":: Start Hyprland now? (Y/n) " start_answer
      if [[ -z "$start_answer" || "$start_answer" =~ ^[Yy]$ ]]; then
          echo ":: Starting Hyprland..."
          start-hyprland
      else
          echo ":: Rebooting..."
          sleep 1 && reboot
      fi
    ;;
    [Nn]* )
        echo ":: Exiting..."
    ;;
    * )
        echo "Invalid input. please answer Y or n."
        exit 1
    ;;
esac
