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

checkLineThenAppend "./hosts" "/etc/hosts"

## Set up IPv4 bridge on all nodes
#Load the following kernel modules on all nodes
# Overlay module provides overlay filesystem support, used for k8s pod network abstraction.
# br_netfiler enables bridge netfilter support in the Linux Kernal, which is required for kubernetes networking and policy

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Loads the overlay kernel module into the running kernel
sudo modprobe overlay
# Loads the br_netfilter module into the running kernel
sudo modprobe br_netfilter

# Verify br_netfilter, overlay are loaded
lsmod | grep br_netfilter
lsmod | grep overlay

# Set the following kernal parameters for kubernetes
# params persists across reboots

#net.bridge.bridge-nf-call-iptables and net.bridge.bridge-nf-call-ip6tables enable bridged IPv4 and IPv6 traffic to be passed to iptables chains
# required for kubernetes networking policies and traffic routing to work
# net.ipv4.ip_forward enables IP forwarding in the kernal, required for packet routing between pods in Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

## Installing packages on all nodes
#
# Containerd container runtime

apt update -y
sudo apt-get -y -qq install curl wget gnupg git vim apt-transport-https ca-certificates libguestfs-tools
sudo apt install btop htop tmux

## Install with public signing key
# Create a folder to store the signing key
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Add the appropriate Kubernetes apt repository. If you want to use Kubernetes version different than v1.29, replace v1.29 with the desired minor version in the command below:

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Checking pat package index and see new items..."

sudo apt-get update

echo "Installing kubectl, kubelet, kubeadm..."
sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00

echo "Kubelet, kubeadm and kubectl installation completed, now installing docker..."
sudo apt install docker.io

echo "Finished installing docker, installing containerd...."
apt install -y containerd

echo "Creating /etc/containerd to hold containerd configuration file..."
# create the /etc/containerd directory to hold the containerd configuration file.
sudo mkdir -p /etc/containerd
# generate a default config for containerd and outputs it to stdout
# default config output is piped to tee and writes to /etc/containerd/config.toml
echo "Creating default configuration file for containerd and save it as config.toml..."
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Kubernetes requires all its components and container runtime uses systemd for cgroups
echo "Modifying config.toml to locate the entry that sets 'SystemdCgroup' to false and reset it to true..."
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml

echo "Restarting containerd and kubelet services to apply all changes..."
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service
echo "Start kubelet service whenever machine reboots, run"
echo "sudo systemctl enable kubelet.service"
