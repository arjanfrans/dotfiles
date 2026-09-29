#!/usr/bin/env bash
set -euo pipefail

UBUNTU_DIR="$(cd "$(dirname "$0")" && pwd)"
MIRRORS=(
    https://ubuntu.anexia.at/ubuntu-releases
    https://mirror.kumi.systems/ubuntureleases
    https://releases.ubuntu.com
)
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/ubuntu-usb"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

latest_lts_codename() {
    curl -fsSL https://changelogs.ubuntu.com/meta-release-lts \
        | awk '/^Dist:/ {dist=$2} /^Version:.*LTS/ {latest=dist} END {print latest}'
}

download_iso() {
    local codename="$1" line name sum mirror

    line="$(curl -fsSL "https://releases.ubuntu.com/$codename/SHA256SUMS" | grep -E 'desktop-amd64\.iso$' | sort -k2 -V | tail -1)"
    sum="${line%% *}"
    name="${line##*\*}"
    ISO="$CACHE/$name"

    mkdir -p "$CACHE"
    if [ -f "$ISO" ] && echo "$sum  $ISO" | sha256sum -c --status; then
        echo "==> Using cached $name"
        return
    fi

    for mirror in "${MIRRORS[@]}"; do
        echo "==> Downloading $name from $mirror"
        curl -fL -C - -o "$ISO" "$mirror/$codename/$name" && break
    done
    if ! echo "$sum  $ISO" | sha256sum -c; then
        rm -f "$ISO"
        exit 1
    fi
}

write_grub_cfg() {
    xorriso -osirrox on -indev "$ISO" -extract /boot/grub/grub.cfg "$WORK/grub.orig.cfg" 2>/dev/null
    awk '
        /^set timeout=/ { print "set timeout=10"; next }
        /^menuentry/ && !done { inside = 1 }
        inside {
            entry = entry $0 "\n"
            if ($0 ~ /^}/) {
                auto = entry
                sub(/"[^"]*"/, "\"Autoinstall Ubuntu\"", auto)
                sub(/\/casper\/[^ \t]*vmlinuz[^ \t]*/, "& autoinstall", auto)
                printf "%s%s", auto, entry
                inside = 0; done = 1; entry = ""
            }
            next
        }
        { print }
    ' "$WORK/grub.orig.cfg" > "$WORK/grub.cfg"
}

build_iso() {
    OUT="$CACHE/autoinstall-$(basename "$ISO")"
    echo "==> Building $OUT"
    rm -f "$OUT"
    xorriso -indev "$ISO" -outdev "$OUT" \
        -map "$UBUNTU_DIR/autoinstall.yaml" /autoinstall.yaml \
        -map "$UBUNTU_DIR/first-login.sh" /first-login.sh \
        -map "$WORK/grub.cfg" /boot/grub/grub.cfg \
        -boot_image any replay
}

select_usb() {
    local devices
    mapfile -t devices < <(lsblk -dnpo NAME,TRAN,SIZE,MODEL | awk '$2 == "usb"')
    if [ ${#devices[@]} -eq 0 ]; then
        echo "No USB drives found."
        exit 1
    fi

    echo "Select the USB drive to overwrite:"
    select choice in "${devices[@]}"; do
        [ -n "$choice" ] && break
    done
    USB="${choice%% *}"

    lsblk "$USB"
    read -rp "All data on $USB will be lost. Type 'yes' to continue: " confirm
    [ "$confirm" = "yes" ] || exit 1
}

unmount_usb() {
    local part
    for part in $(lsblk -lnpo NAME "$USB" | tail -n +2); do
        findmnt -rn -S "$part" >/dev/null || continue
        udisksctl unmount -b "$part" >/dev/null 2>&1 || sudo umount "$part"
    done
    if lsblk -lnpo MOUNTPOINTS "$USB" | grep -q .; then
        echo "$USB is still mounted, aborting."
        exit 1
    fi
}

write_usb() {
    echo "==> Writing to $USB"
    unmount_usb
    sudo dd if="$OUT" of="$USB" bs=4M status=progress oflag=direct conv=fsync
    sync
    rm -f "$OUT"
}

command -v xorriso >/dev/null || sudo apt-get install -y xorriso

CODENAME="$(latest_lts_codename)"
echo "==> Latest LTS: $CODENAME"
download_iso "$CODENAME"
write_grub_cfg
build_iso
select_usb
write_usb

echo "Done. Boot from the USB drive and pick 'Autoinstall Ubuntu'."
