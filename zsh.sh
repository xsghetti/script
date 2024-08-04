#!/bin/bash

SOURCE_DIR=~/hyprcrux/src/


echo "Installing Zsh, Oh-My-Zsh, and Powerlevel10k..."
sudo pacman -S --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


cp $SOURCE_DIR/.zshrc ~/

cp $SOURCE_DIR/.p10k.zsh ~/

chsh -s $(which zsh)
