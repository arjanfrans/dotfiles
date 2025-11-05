#!/bin/bash

# 1. Check if Docker is already installed
if command -v docker &> /dev/null
then
    echo "Docker is already installed. Skipping installation."
    docker --version
    exit 0
else
    echo "Docker not found. Proceeding with installation..."
fi

# 2. Install prerequisites
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# 3. Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

echo "--- Post-installation steps ---"

# 6. Add current user to the docker group
sudo usermod -aG docker $USER

# 7. Set permissions for .docker directory (checking if it exists)
if [ -d "$HOME/.docker" ]; then
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R
fi

# 8. Enable Docker services
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

echo -e "\n--- Docker Installation Complete ---"
echo "IMPORTANT: Log out and log back in for group changes to take effect."

# 9. Apply group changes to the current session
# Note: This is temporary for this shell. A full re-log is required.
newgrp docker
