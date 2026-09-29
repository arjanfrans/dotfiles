ARCHIVE="phpstorm.tar.gz"
INSTALL_DIR="$HOME/.local/phpstorm"

if [ ! -x "$INSTALL_DIR/bin/phpstorm" ]; then
    curl -L "https://download.jetbrains.com/product?code=PS&latest&distribution=linux" -o "/tmp/${ARCHIVE}"
    mkdir -p "$INSTALL_DIR"
    tar -xzf "/tmp/${ARCHIVE}" -C "$INSTALL_DIR" --strip-components=1
    rm "/tmp/${ARCHIVE}"
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_DIR/bin/phpstorm" "$HOME/.local/bin/phpstorm"

mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/jetbrains-phpstorm.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PhpStorm
Icon=$INSTALL_DIR/bin/phpstorm.svg
Exec="$INSTALL_DIR/bin/phpstorm" %f
Comment=The Lightning-Smart PHP IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
StartupNotify=true
EOF

FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
case "$FAVORITES" in
    *jetbrains-phpstorm.desktop*) ;;
    *) gsettings set org.gnome.shell favorite-apps "${FAVORITES%]*}, 'jetbrains-phpstorm.desktop']" ;;
esac
