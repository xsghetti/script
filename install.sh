pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

sudo pacman -S --needed - < ~/script/pacman.txt
yay -S - < ~/script/yay.txt

cd ~/script/
./clone.sh


