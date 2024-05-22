#!/bin/sh
set -e

read -p "Please monitor the installation and provide input as required. Press enter to continue..." input

# Get kubectl for kubernetes management
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Validate binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
read -p "Make sure that the validation check was OK, and press enter to continue, otherwise stop the script CTRL+C and restart it" input

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Check succesfull installation
kubectl version --client

# Install K3d
echo "Starting K3d installation"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
