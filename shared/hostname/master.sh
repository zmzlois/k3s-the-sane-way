#!/usr/bin/env bash

set -xeuo pipefail

# set hostname
sudo hostnamectl set-hostname "k8s-master"
sudo DEBIAN_FRONTEND=noninteractive

# Several components "kube-apiserver", "kube-controller-manager, kube-scheduler, etcd, kube-proxy" are used to to manage and orchestrate the cluster when a Kubernetes control plane is using kubeadm
echo "Initialising Kubernetes cluster on master node..."
sudo kubeadm config images pull

echo "initialise mster node, setting --pod-network-cidr flag for IP address range..."
sudo kubeadm init --pod-network-cidr=10.10.0.0/16

echo "Configuring kubectl..."
echo "Creating .kube directory at $HOME..."
mkdir -p $HOME/.kube

echo "Copying cluster's admin configuration to personal .kube directory..."
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

echo "Changing ownership and R/W permission of copied file..."
sudo chown $(id -u):$(id -g) $HOME/.kube/config
