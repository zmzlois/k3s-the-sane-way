#!/usr/bin/env bash

set -xeuo pipefail

source ../shared/utils.sh
source ./.profile

# Read the content of the file into a variable
echo "Accessing token from worker node to join the cluster..."
TOKEN=$(cat ./token)

# Print the content of the variable
echo "$file_content"

echo "Setting hostname for worker node in Frankfurt..."
sudo hostnamectl set-hostname "k8s-worker-frankfurt"

echo "Installing k3s and joining control plane..."
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.22.5+k3s2 K3S_URL=https://94.72.100.82:6443 K3S_TOKEN=$TOKEN sh -

echo "Checking k3s is running on worker node in frankfurt..."
systemctl status k3s-agent
