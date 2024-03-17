#!/usr/bin/env bash

# This preparation file is for both control plane and worker nodes to get prepared + ready for kubernetes

set -xeuo pipefail

# SSH_PUBLIC_KEY=${{ secrets.SSH_PUBLIC_KEY }}
# AUTHORIZED_KEY_FILE="~/.ssh/authorized_keys"
HOST_FILE="./hosts"

# Source the utility file and use functions there
source ./utils.sh

# automatic update of critical packages
sudo apt-get update -y
# sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

sudo dpkg-reconfigure -low unattended-upgrades
sudo apt-get update

apt update -y
sudo apt-get -y -qq install curl wget gnupg git vim apt-transport-https ca-certificates libguestfs-tools
sudo apt install btop htop tmux
## Ubuntu set up
# # Create a new directory for ubuntu
# mkdir /debian-custom
# cd /debian-custom
# wget -O deb11custom.qcow2 https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2

## Configure SSH (Commenting this out to keep the logic, as we will set the SSH keys ourselves)
# Check if ssh/authorized_keys file exists
# if [ ! -f "$AUTHORIZED_KEY_FILE" ]; then
#   # if the file doesn't exists, create it
#   touch "$AUTHORIZED_KEY_FILE"
# fi
#
# # Write public key into ~/.ssh/authorized_keys
# if ! grep -q "$SSH_PUBLIC_KEY" "$AUTHORIZED_KEY_FILE" > /dev/null 2>&1; then
#   echo "Public key not found, appending..."
#   echo "$SSH_PUBLIC_KEY" >> "$AUTHORIZED_KEY_FILE"
# else
#   echo "Public key found..."
# fi

# Disable swap to prevent kubernetes degraded performance https://serverfault.com/questions/881517/why-disable-swap-on-kubernetes
# A swap file is used to avoid running out of RAM when using memory-intensive applications. Ubuntu uses swap space to store information that would ordinarily be held in RAM on the hard drive guards against freezes and crashes
# but it can negatively affect performance.

# Run the command and store the output in a variable
# confirm swap is off
output=$(sudo swapon --show)

# Check if there is any output
if [ -n "$output" ]; then
	# If there is output, swap is enabled
	echo "Swap is enabled, disabling..."
	sudo swapoff -a

	# permanently disable swap and make it persists between sets of commands, and siable swap on fs tab
	sudo sed -i '/swap/s/^/#/' /etc/fstab
else
	# If there is no output, swap is disabled
	echo "Swap file is disabled"
fi

## Adjust system time
## System time sync
timedatectl set-ntp on
## show system time
timedatectl

## Set up nvim
# Get nvim in as AppImage, no installation required
mkdir -p /nvim && cd /nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage

# Expose it globally

# Get nvim config in
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

git clone https://github.com/kerwanp/nvim ~/.config/nvim

# Prepare the host file for all hosts

echo "Editing the hosts file..."
checkLineThenAppend "./hosts" "/etc/hosts"
