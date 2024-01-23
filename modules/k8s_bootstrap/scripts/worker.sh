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

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00
sudo apt-mark hold kubelet kubeadm kubectl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

while true; do
  CURRENT_VALUE=$(aws ssm get-parameter --name ${join_token_param} --with-decryption --query "Parameter.Value" --output text)

  if [ "$CURRENT_VALUE" != "placeholder" ]; then
    echo "sudo $CURRENT_VALUE" | bash
    break
  fi
          
  # TODO: Add a timeout
  sleep 5
done