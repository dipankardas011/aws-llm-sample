#!/bin/bash
set -x

# Install necessary dependencies
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get update
sudo apt-get -y -qq install curl wget git vim apt-transport-https ca-certificates
sudo apt install -y ubuntu-drivers-common python3.12-venv python3-pip
sudo ubuntu-drivers autoinstall
sudo apt install -y nvidia-cuda-toolkit

# Setup sudo to allow no-password sudo for "hashicorp" group and adding "terraform" user
sudo groupadd -r hashicorp
sudo useradd -m -s /bin/bash terraform
sudo usermod -a -G hashicorp terraform
sudo cp /etc/sudoers /etc/sudoers.orig
echo "terraform  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/terraform

# Installing SSH key
sudo mkdir -p /home/terraform/.ssh
sudo chmod 700 /home/terraform/.ssh
sudo cp /tmp/tf-packer.pub /home/terraform/.ssh/authorized_keys
sudo chmod 600 /home/terraform/.ssh/authorized_keys
sudo chown -R terraform /home/terraform/.ssh
sudo usermod --shell /bin/bash terraform

sudo -H -i -u ubuntu -- env bash << EOF
whoami
echo ~ubuntu

cd /home/ubuntu

mkdir -p vllm && cd vllm

python3 -m venv venv

echo 'source /home/ubuntu/vllm/venv/bin/activate' >> ~/.bashrc
source /home/ubuntu/vllm/venv/bin/activate
sudo pip install vllm
EOF
