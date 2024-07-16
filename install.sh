pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

sudo pacman -S --needed - < ~/script/pacman.txt
yay -S - < ~/script/yay.txt

git clone https://github.com/xsghetti/hyprcrux

cp -r ~/hyprcrux/.config/* ~/.config/
sudo cp -r ~/hyprcrux/src/icons/* /usr/share/icons/
sudo cp -r ~/hyprcrux/src/fonts/* /usr/share/fonts/
sudo cp -r ~/hyprcrux/src/themes/* /usr/share/themes/

