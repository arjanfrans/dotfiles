#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository ppa:openshot.developers/ppa
sudo apt update
sudo apt install openshot-qt python3-openshot
