#!/bin/bash

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        echo "Please do not run this script as root"
        exit 1
    fi
}

# Function to install pip if not present
install_pip() {
    if ! command -v pip &> /dev/null; then
        echo "pip not found. Installing python-pip..."
        sudo pacman -S --needed --noconfirm python-pip
    fi
}

# Function to install terminaltexteffects
install_tte() {
    if ! command -v tte &> /dev/null; then
        pip install terminaltexteffects --break-system-packages &> /dev/null
    fi
}

# Check prerequisites
check_root
install_pip
install_tte

# Display ASCII art with effects
tte beams << "EOF"
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
      
      #Download and Install Yay
      echo ":: Installing Yay AUR helper..."
      sudo pacman -S --needed git base-devel
      git clone https://aur.archlinux.org/yay-bin.git
      cd yay-bin
      makepkg -si
      
      #Download and Install packages
      echo ":: Installing packages..."
      yay -S --needed - < ~/script/src/yay.txt
      
      #Clones Hyprcrux Repo and copies them to their correct locations.
      echo ":: Cloning Hyprcrux configuration..."
      cd ~/script/
      ./clone.sh
      
      echo ":: Restoring ZSH"
      ~/script/zsh.sh
      
      echo ":: Installing Grub Theme"
      ~/script/grub.sh
      ~/script/greetd.sh
      
      echo ":: Rebooting"
      sudo systemctl enable bluetooth && sudo systemctl start bluetooth
      sudo systemctl enable greetd && sudo systemctl start greetd
      sleep 1 && reboot
    ;;
    [Nn]* )
        echo ":: Exiting..."
    ;;
    * )
        echo "Invalid input. please answer Y or n."
        exit 1
    ;;
esac
