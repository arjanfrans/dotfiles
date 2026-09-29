ARCHIVE="phpstorm.tar.gz"
INSTALL_DIR="$HOME/.local/phpstorm"

curl -L "https://download.jetbrains.com/product?code=PS&latest&distribution=linux" -o "/tmp/${ARCHIVE}"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "/tmp/${ARCHIVE}" -C "$INSTALL_DIR" --strip-components=1

ln -sf "$INSTALL_DIR/bin/phpstorm" "$HOME/.local/bin/phpstorm"

rm "/tmp/${ARCHIVE}"
