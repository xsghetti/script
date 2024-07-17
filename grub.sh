#!/bin/bash
echo ":: Installing Grub Theme"
cd ..
git clone https://github.com/catppuccin/grub.git && cd grub
sudo cp -r ~/script/src/catppuccin-mocha/ /usr/share/grub/themes/
sudo cp ~/script/src/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

