#!/bin/sh
set -e

read -p "Please monitor the installation and provide input as required. Press enter to continue..." input

# Get official docker install script
curl -fsSL https://get.docker.com -o get-docker.sh

# Dry - run to see the changes
# echo "The following actions will be performed:"
# sh get-docker.sh --dry-run
# read -p "Press enter to continue if you agree with the above actions or cancel the script..." input

# Start installation
sudo sh get-docker.sh


# Use docker as non root
#sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Autostart, is already performed by the script for debian and ubuntu based distributions
# sudo systemctl enable docker.service
# sudo systemctl enable containerd.service

echo 'If no errors occurred installation of docker engine is complete'


# For uninstall
# sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd
