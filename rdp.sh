#!/bin/bash

# Set default username and password
username="user"
password="root"

# Set default CRP value
CRP=""

# Set default Pin value
Pin="123456"

# Set default Autostart value
Autostart=true

echo "Creating User and Setting it up"
sudo useradd -m "$username"
sudo adduser "$username" sudo
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo "User created and configured with username '$username' and password '$password'"

echo "Installing Ubuntu Desktop and necessary packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install --assume-yes ubuntu-desktop wget

echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install --assume-yes --fix-broken

echo "Installing Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install --assume-yes --fix-broken

echo "Disabling the default display manager to prevent conflicts"
sudo systemctl disable gdm3.service

echo "Configuring Chrome Remote Desktop to use the GNOME session"
sudo tee /etc/chrome-remote-desktop-session > /dev/null <<EOL
export XDG_SESSION_TYPE=x11
export GNOME_SHELL_SESSION_MODE=ubuntu
exec /usr/bin/gnome-session
EOL

# Prompt user for CRP value
read -p "Enter CRP value: " CRP

echo "Finalizing Setup"
if [ "$Autostart" = true ]; then
    mkdir -p "/home/$username/.config/autostart"
    link="https://youtu.be/d9ui27vVePY?si=TfVDVQOd0VHjUt_b"
    colab_autostart="[Desktop Entry]\nType=Application\nName=Colab\nExec=sh -c 'sensible-browser $link'\nIcon=\nComment=Open a predefined notebook at session signin.\nX-GNOME-Autostart-enabled=true"
    echo -e "$colab_autostart" | sudo tee "/home/$username/.config/autostart/colab.desktop"
    sudo chmod +x "/home/$username/.config/autostart/colab.desktop"
    sudo chown "$username:$username" "/home/$username/.config" -R
fi

sudo adduser "$username" chrome-remote-desktop
command="$CRP --pin=$Pin"

echo "Starting Chrome Remote Desktop service for user $username"
sudo su - "$username" -c "$command"
sudo service chrome-remote-desktop start

echo "Finished Successfully. The remote desktop should be available shortly."
while true; do sleep 10; done
