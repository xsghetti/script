#!/bin/bash
echo ":: Installing Grub Theme"1
sudo cp -r ~/script/src/cyberpunk_arcade/ /usr/share/grub/themes/
sudo cp -r ~/script/src/grub /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg

