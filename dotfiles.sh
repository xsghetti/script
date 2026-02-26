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

read -p ":: Apply Hyprcrux dotfiles? (Y/n) " answer

# Set default to Yes if empty
if [[ -z "$answer" ]]; then
    answer="Y"
fi

case $answer in
    [Yy]* )
        echo ":: Cloning Hyprcrux configuration..."
        cd ~/script/
        ./clone.sh

        echo ":: Restoring ZSH"
        ~/script/zsh.sh

        echo ":: Dotfiles applied!"
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
