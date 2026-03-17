#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing Docker dependencies..."
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing docker-compose standalone..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# Optional: create symlink
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Creating user 'devsecops'..."
sudo useradd -m -s /bin/bash devsecops

echo "Setting password for 'devsecops'..."
sudo passwd devsecops

echo "Adding 'devsecops' to sudo group..."
sudo usermod -aG sudo devsecops

echo "Adding 'devsecops' to docker group..."
sudo usermod -aG docker devsecops

echo "Setting up SSH access for 'devsecops'..."
sudo mkdir -p /home/devsecops/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/devsecops/.ssh/
sudo chown -R devsecops:devsecops /home/devsecops/.ssh
sudo chmod 700 /home/devsecops/.ssh
sudo chmod 600 /home/devsecops/.ssh/authorized_keys

echo "Verifying Docker..."
docker --version

echo "Verifying Docker Compose (plugin)..."
docker compose version

echo "Verifying docker-compose (standalone)..."
docker-compose --version

echo "Applying docker group changes..."
newgrp docker

echo "You can now SSH using: ssh devsecops@<your-ec2-public-ip>"
