#!/bin/bash
cd ..
# Clone the repository
git clone https://github.com/xsghetti/hyprcrux

# Copy the configuration files
cp -r ~/hyprcrux/.config/* ~/.config/

# Copy icons, fonts, and themes to their respective system directories
sudo cp -r ~/hyprcrux/src/icons/* /usr/share/icons/
sudo cp -r ~/hyprcrux/src/fonts/* /usr/share/fonts/
sudo cp -r ~/hyprcrux/src/themes/* /usr/share/themes/
