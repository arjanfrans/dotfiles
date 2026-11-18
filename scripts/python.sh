#!/usr/bin/env bash
set -euo pipefail

sudo apt install python3-pip python3-full python3-virtualenv pipx -y
python3 -m venv ~/py-venv
