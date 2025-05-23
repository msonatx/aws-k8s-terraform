#!/bin/bash
new_name=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
sudo hostnamectl set-hostname $new_name

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl status containerd
sudo swapoff -a
sudo apt-get update && sudo apt-get install -y apt-transport-https curl unzip
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.30

# Configure kubectl for current/root user to allow calico to install
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Configure kubectl for ubuntu user just to save time
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubeadm token create --print-join-command)