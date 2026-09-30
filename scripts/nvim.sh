#!/usr/bin/env bash
set -euo pipefail

# Neovim (official release, apt lags behind)
sudo apt-get remove -y neovim neovim-runtime python3-neovim
sudo rm -rf /opt/nvim-linux-x86_64
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | sudo tar -C /opt -xz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# tree-sitter CLI (nvim-treesitter needs a newer one than apt has)
TS_TMP="$(mktemp)"
curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
    | gunzip > "$TS_TMP"
sudo install -m 0755 "$TS_TMP" /usr/local/bin/tree-sitter
rm -f "$TS_TMP"

# Nerd Font for icons
FONT_DIR="$HOME/.dotfiles/fonts/nerd/SourceCodePro"
mkdir -p "$FONT_DIR"
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.tar.xz \
    | tar -C "$FONT_DIR" -xJ

mkdir -p ~/.dotfiles/nvim/.tmp
