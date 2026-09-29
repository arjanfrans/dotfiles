#!/usr/bin/env bash
set -euo pipefail

# GitLab CLI (latest .deb from the official releases)
DEB_URL="$(curl -fsSL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest" \
    | grep -oE 'https://[^"]*linux_amd64\.deb' | head -1)"
curl -fsSL "$DEB_URL" -o /tmp/glab.deb
sudo apt install -y /tmp/glab.deb
rm /tmp/glab.deb

# SSH key (created by gh.sh)
KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEY" ]; then
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$KEY"
fi

# Trust GitLab's host key
if ! ssh-keygen -F gitlab.com >/dev/null; then
    ssh-keyscan -t ed25519 gitlab.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

# Log in
if ! glab auth status --hostname gitlab.com >/dev/null 2>&1; then
    glab auth login --hostname gitlab.com
fi

# Upload the key, unless GitLab already has it
PUBKEY="$(cut -d' ' -f1,2 "$KEY.pub")"
if ! glab api user/keys | grep -qF "$PUBKEY"; then
    glab ssh-key add "$KEY.pub" --title "$(hostname)" --usage-type auth
fi
