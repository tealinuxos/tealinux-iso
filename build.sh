#!/bin/bash
sudo sed -i "s|Server = file://.*|Server = file://$(pwd)/localrepo/|" ./tealinux/pacman.conf

start_time=$(date +%s)

# Ensure lorem-loader theme is available in both locations
LOREM_URL="https://github.com/tealinuxos/lorem-loader.git"
GRUB_THEME_DIR="tealinux/grub/lorem-loader"
AIROOTFS_THEME_DIR="tealinux/airootfs/usr/share/grub/themes/lorem-loader"

if [ ! -f "$GRUB_THEME_DIR/assets/theme.txt" ]; then
    echo "[build] Cloning lorem-loader theme..."
    rm -rf "$GRUB_THEME_DIR"
    git clone --depth=1 "$LOREM_URL" "$GRUB_THEME_DIR"
fi

if [ ! -f "$AIROOTFS_THEME_DIR/assets/theme.txt" ]; then
    echo "[build] Syncing lorem-loader to airootfs..."
    mkdir -p "$AIROOTFS_THEME_DIR"
    rsync -a --delete "$GRUB_THEME_DIR/" "$AIROOTFS_THEME_DIR/"
fi

# Build ISO
sudo rm -rf .work
time sudo systemd-inhibit mkarchiso -r -v -w .work -o out tealinux

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

notify-send -u critical "Tealinux Build" "Exited. done in $elapsed_time seconds"
mpv notif.mp3 > /dev/null 2>&1 &
