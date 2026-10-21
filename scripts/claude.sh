curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
"$HOME/.local/bin/rtk" init -g
curl -fsSL https://github.com/rtk-ai/rtk/releases/latest/download/rtk-proxy-x86_64-unknown-linux-musl.tar.gz | tar -xz -C "$HOME/.local/bin" rtk-proxy
"$HOME/.local/bin/rtk-proxy" service install --bind 127.0.0.1:9654

mkdir -p ~/.claude/skills
for skill in "$HOME"/.dotfiles/private/skills/*/; do
    [ -d "$skill" ] || continue
    dest=~/.claude/skills/"$(basename "$skill")"
    rm -rf "$dest"
    ln -s "${skill%/}" "$dest"
done
