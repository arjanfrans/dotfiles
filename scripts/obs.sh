#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt install obs-studio
