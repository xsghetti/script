#!/bin/bash

SOURCE_DIR=~/hyprcrux/src/


echo "Installing Zsh, Oh-My-Zsh, and Powerlevel10k..."
sudo pacman -S --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp -r src/powerlevel10k ~/.oh-my-zsh/custom/themes/
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


cp $SOURCE_DIR/.zshrc ~/

cp $SOURCE_DIR/.p10k.zsh ~/

sudo usermod -s $(which zsh) $USER
