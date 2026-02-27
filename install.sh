#!/bin/bash

# Resolve script directory (works regardless of where it's cloned)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Error helper
die() { echo ":: ERROR: $1" >&2; exit 1; }

# Reject root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# --- Shared functions ---

install_yay() {
    if ! command -v yay &>/dev/null; then
        echo ":: Installing Yay AUR helper..."
        sudo pacman -S --needed --noconfirm git base-devel
        rm -rf "$SCRIPT_DIR/yay-bin"
        git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$SCRIPT_DIR/yay-bin"
        cd "$SCRIPT_DIR/yay-bin"
        makepkg -si --noconfirm || die "Failed to build yay"
        cd "$SCRIPT_DIR"
        rm -rf "$SCRIPT_DIR/yay-bin"
    else
        echo ":: Yay already installed, skipping..."
    fi
}

clone_hyprcrux() {
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
}

setup_zsh() {
    echo ":: Restoring ZSH..."
    sudo pacman -S --noconfirm zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    cp -r "$SCRIPT_DIR/src/powerlevel10k" ~/.oh-my-zsh/custom/themes/

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
        git -C "$zsh_custom/plugins/zsh-syntax-highlighting" pull
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    fi

    if [ -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
        git -C "$zsh_custom/plugins/zsh-autosuggestions" pull
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    fi

    if [ -d "$zsh_custom/plugins/fzf-tab" ]; then
        git -C "$zsh_custom/plugins/fzf-tab" pull
    else
        git clone https://github.com/Aloxaf/fzf-tab "$zsh_custom/plugins/fzf-tab"
    fi

    cp ~/hyprcrux/src/.zshrc ~/
    cp ~/hyprcrux/src/.p10k.zsh ~/
    sudo usermod -s "$(which zsh)" "$USER"
}

prompt_finish() {
    local msg="$1"
    echo ""
    echo ":: $msg"
    echo "  :: What would you like to do?"
    echo "  1) Start Hyprland"
    echo "  2) Reboot"
    echo "  3) Exit"
    echo ""
    read -p "  Enter choice [1/2/3]: " finish_choice

    case $finish_choice in
        1)
            echo ":: Starting Hyprland..."
            cd "$HOME" && exec Hyprland
            ;;
        2)
            echo ":: Rebooting..."
            sleep 1 && reboot
            ;;
        *)
            echo ":: Exiting. Enjoy Hyprcrux!"
            cd "$HOME" && exec zsh -l
            ;;
    esac
}

# --- Banner ---

PYTHONPATH="$SCRIPT_DIR/src/tte" python -m terminaltexteffects beams << "EOF"
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
        sudo cp "$SCRIPT_DIR/src/mkinitcpio.conf" /etc/mkinitcpio.conf

        echo ":: Setting up NVIDIA modules..."
        sudo cp "$SCRIPT_DIR/src/nvidia.conf" /etc/modprobe.d/nvidia.conf

        sudo mkinitcpio -P || die "mkinitcpio failed"

        install_yay

        echo ":: Installing packages..."
        yay -S --needed --noconfirm - < "$SCRIPT_DIR/src/yay.txt" || die "Package installation failed"

        clone_hyprcrux
        setup_zsh

        echo ":: Installing Grub Theme..."
        sudo cp -r "$SCRIPT_DIR/src/cyberpunk_arcade/" /usr/share/grub/themes/
        sudo cp "$SCRIPT_DIR/src/grub" /etc/default/
        sudo grub-mkconfig -o /boot/grub/grub.cfg || die "grub-mkconfig failed"

        echo ":: Configuring greetd..."
        sudo cp "$SCRIPT_DIR/src/config.toml" /etc/greetd/

        sudo systemctl enable --now bluetooth
        sudo systemctl enable --now greetd

        prompt_finish "Installation complete!"
        ;;

    2)
        echo ""
        echo ":: Dotfiles-only install selected."

        install_yay

        echo ":: Installing noctalia-shell-git..."
        yay -S --needed --noconfirm noctalia-shell-git

        clone_hyprcrux
        setup_zsh

        prompt_finish "Dotfiles applied!"
        ;;

    *)
        echo ":: Invalid choice. Exiting."
        exit 1
        ;;
esac
