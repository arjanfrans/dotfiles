#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository ppa:linrunner/tlp -y
sudo apt update
sudo apt install tlp tlp-rdw -y
sudo systemctl enable tlp.service
