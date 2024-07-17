#/bin/bash
cat << "EOF"
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
                             ©xSghetti 2024
-----------------------------------------------------------------------
EOF
echo ":: WARNING! This script is meant for Nvidia users only! It installs the nvidia-dkms and nvidia-utils packages"
read -p "Do you want to continue? (y/n) " answer

case $answer in
    [Yy]* )
      echo ":: Install Continuing..."
      #Copy mkinitcpio.conf
      sudo cp -r ~/script/src/mkinitcpio.conf /etc/mkinitcpio.conf
        
      #Make /etc/modprobe.d/nvidia.conf
      sudo touch /etc/modprobe.d/nvidia.conf
      sudo cp -r ~/script/src/nvidia.conf /etc/modprobe.d/nvidia.conf
      
      sudo mkinitcpio -P
      
      #Download and Install Yay
      pacman -S --needed git base-devel
      git clone https://aur.archlinux.org/yay-bin.git
      cd yay-bin
      makepkg -si
      
      #Download and Install packages
      sudo pacman -S --needed - < ~/script/src/pacman.txt
      yay -S --needed - < ~/script/src/yay.txt
      
      #Clones Hyprcrux Repo and copies them to their correct locations.
      cd ~/script/
      ./clone.sh
      
      
      echo ":: Preparing to Install HyprPM Plugins..."
      sleep 5
      ~/script/hyprpm.sh
      
      echo ":: Preparing to Install Grub Theme"
      ~/script/grub.sh
      
      echo ":: Preparing to Install SDDM Theme"
      ~/script/sddm.sh
      
      echo ":: Rebooting"
      sleep 15
      sudo reboot
    ;;
    [Nn]* )
        echo ":: Exiting..."
    ;;
    * )
        echo "Invalid input. please answer y or n."
        exit 1
    ;;
esac

