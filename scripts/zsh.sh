#!/bin/bash

# 1. Install zsh
# Installs the Z shell using apt-get
echo "Installing zsh..."
sudo apt-get install zsh -y

# Define the default Oh My Zsh installation directory
OMZ_DIR="$HOME/.oh-my-zsh"

# 3. Check if Oh My Zsh is already installed
echo "Checking for existing Oh My Zsh installation..."
if [ -d "$OMZ_DIR" ]; then
  echo "Oh My Zsh is already installed in $OMZ_DIR. Skipping installation."
else
  echo "Oh My Zsh not found. Installing..."
  # 4. Install Oh My Zsh if it's not already there
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi
