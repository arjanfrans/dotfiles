#!/usr/bin/env bash
set -euo pipefail

# GitHub CLI (official apt repo)
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# SSH key
KEY="$HOME/.ssh/id_ed25519"
mkdir -p -m 700 "$HOME/.ssh"
if [ ! -f "$KEY" ]; then
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$KEY"
fi

# Trust GitHub's host key, so the first clone doesn't prompt
if ! ssh-keygen -F github.com >/dev/null; then
    ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

# Log in (with permission to manage SSH keys)
if ! gh auth status >/dev/null 2>&1; then
    gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key --scopes admin:public_key
elif ! gh auth status 2>&1 | grep -q admin:public_key; then
    gh auth refresh --hostname github.com --scopes admin:public_key
fi

# Upload the key, unless GitHub already has it
PUBKEY="$(cut -d' ' -f1,2 "$KEY.pub")"
if ! gh api user/keys --jq '.[].key' | grep -qxF "$PUBKEY"; then
    gh ssh-key add "$KEY.pub" --title "$(hostname)"
fi
