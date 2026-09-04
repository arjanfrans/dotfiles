VERSION="2025.3.2.6"
NAME="panda2"
ARCHIVE="android-studio-${NAME}-linux.tar.gz"
INSTALL_DIR="$HOME/.local/android-studio"

curl -L "https://edgedl.me.gvt1.com/android/studio/ide-zips/${VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "/tmp/${ARCHIVE}" -C "$HOME/.local" --strip-components=1 --one-top-level=android-studio

ln -sf "$INSTALL_DIR/bin/studio" "$HOME/.local/bin/android-studio"

rm "/tmp/${ARCHIVE}"
