OLD_PACKAGES=$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc 2>/dev/null | cut -f1)
if [ -n "$OLD_PACKAGES" ]; then
    sudo apt remove -y $OLD_PACKAGES
fi

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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

