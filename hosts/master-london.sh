#!/usr/bin/env bash

set -xeuo pipefail

source ../shared/utils.sh
source ./.profile

# set hostname
sudo hostnamectl set-hostname "k8s-master"

echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -

echo "Copying the kubeconfig file to the local machine..."
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

echo "Setting the kubeconfig file to the right permissions..."
chmod 600 ~/.kube/config

echo "Accesing token for worker nodes to join the cluster..."
checkLineThenAppend "/var/lib/rancher/k3s/server/node-token" "./token"

echo "Checking k3s is running on control plane..."
systemctl status k3s-agent
