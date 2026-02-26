#!/bin/bash

# Reject root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# Banner
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

echo ""
echo "  :: Select an option:"
echo "  1) Total Install"
echo "  2) Dotfiles Only"
echo ""
read -p "  Enter choice [1/2]: " mode

case $mode in
    1)
        echo ""
        echo ":: WARNING! This script is meant for Nvidia users only!"
        echo ":: It no longer installs the nvidia-dkms and nvidia-utils packages, but it does apply Nvidia modules."
        read -p ":: Continue? (Y/n) " confirm
        [[ -z "$confirm" ]] && confirm="Y"
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo ":: Exiting..."
            exit 0
        fi

        echo ":: Configuring mkinitcpio..."
        sudo cp -r ~/script/src/mkinitcpio.conf /etc/mkinitcpio.conf

        echo ":: Setting up NVIDIA modules..."
        sudo touch /etc/modprobe.d/nvidia.conf
        sudo cp -r ~/script/src/nvidia.conf /etc/modprobe.d/nvidia.conf

        sudo mkinitcpio -P

        if ! command -v yay &>/dev/null; then
            echo ":: Installing Yay AUR helper..."
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay-bin.git
            cd yay-bin
            makepkg -si
            cd ~/script/
        else
            echo ":: Yay already installed, skipping..."
        fi

        echo ":: Installing packages..."
        yay -S --needed --noconfirm - < ~/script/src/yay.txt

        echo ":: Cloning Hyprcrux configuration..."
        cd ~/script/
        if [ -d ~/hyprcrux ]; then
            echo ":: hyprcrux already cloned, pulling latest changes..."
            git -C ~/hyprcrux pull
        else
            git clone https://github.com/xsghetti/hyprcrux ~/hyprcrux
        fi
        cp -r ~/hyprcrux/.config/* ~/.config/
        sudo cp -r ~/hyprcrux/src/icons/* /usr/share/icons/
        sudo cp -r ~/hyprcrux/src/fonts/* /usr/share/fonts/
        sudo cp -r ~/hyprcrux/src/themes/* /usr/share/themes/
        sudo cp ~/hyprcrux/dashboard.sh /usr/local/bin/dashboard
        sudo chmod +x /usr/local/bin/dashboard

        echo ":: Restoring ZSH..."
        sudo pacman -S --noconfirm zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        cp -r ~/script/src/powerlevel10k ~/.oh-my-zsh/custom/themes/
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab 
        cp ~/hyprcrux/src/.zshrc ~/
        cp ~/hyprcrux/src/.p10k.zsh ~/
        sudo usermod -s $(which zsh) $USER

        echo ":: Installing Grub Theme..."
        sudo cp -r ~/script/src/cyberpunk_arcade/ /usr/share/grub/themes/
        sudo cp -r ~/script/src/grub /etc/default/
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        echo ":: Configuring greetd..."
        sudo cp -r ~/script/src/config.toml /etc/greetd/

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

    2)
        echo ""
        echo ":: Dotfiles-only install selected."

        if ! command -v yay &>/dev/null; then
            echo ":: Installing Yay AUR helper..."
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay-bin.git
            cd yay-bin
            makepkg -si
            cd ~/script/
        else
            echo ":: Yay already installed, skipping..."
        fi

        echo ":: Installing noctalia-shell-git..."
        yay -S --needed --noconfirm noctalia-shell-git

        echo ":: Cloning Hyprcrux configuration..."
        if [ -d ~/hyprcrux ]; then
            echo ":: hyprcrux already cloned, pulling latest changes..."
            git -C ~/hyprcrux pull
        else
            git clone https://github.com/xsghetti/hyprcrux ~/hyprcrux
        fi
        cp -r ~/hyprcrux/.config/* ~/.config/
        sudo cp -r ~/hyprcrux/src/icons/* /usr/share/icons/
        sudo cp -r ~/hyprcrux/src/fonts/* /usr/share/fonts/
        sudo cp -r ~/hyprcrux/src/themes/* /usr/share/themes/
        sudo cp ~/hyprcrux/dashboard.sh /usr/local/bin/dashboard
        sudo chmod +x /usr/local/bin/dashboard

        echo ":: Restoring ZSH..."
        sudo pacman -S --noconfirm zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        cp -r ~/script/src/powerlevel10k ~/.oh-my-zsh/custom/themes/
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
        cp ~/hyprcrux/src/.zshrc ~/
        cp ~/hyprcrux/src/.p10k.zsh ~/
        sudo usermod -s $(which zsh) $USER

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

    *)
        echo ":: Invalid choice. Exiting."
        exit 1
        ;;
esac
