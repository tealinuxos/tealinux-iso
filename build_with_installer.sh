#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update local repo path in pacman.conf
sudo sed -i "s|Server = file://.*|Server = file://${SCRIPT_DIR}/localrepo/|" "${SCRIPT_DIR}/tealinux/pacman.conf"

start_time=$(date +%s)

cd "${SCRIPT_DIR}/localrepo"

echo "==> [1/4] Building tealinux-installer-git (fixes ICU version mismatch)..."
# Remove old packages AND stale git clone cache to force fresh rebuild
rm -f tealinux-installer-git-*.pkg.tar.zst tealinux-installer-git-debug-*.pkg.tar.zst
rm -rf src pkg
# Build installer from source (clones fresh from GitHub, compiles with current system libs)
makepkg -fs --noconfirm
repo-add localrepo.db.tar.xz tealinux-installer-git-*.pkg.tar.zst

echo "==> [2/4] Building tealinux-modularitea-libs..."
cd "${SCRIPT_DIR}/localrepo/tealinux-modularitea-libs"
rm -f tealinux-modularitea-libs-git-*.pkg.tar.zst
makepkg -fs --noconfirm
# Copy to localrepo and add
cp tealinux-modularitea-libs-git-*.pkg.tar.zst "${SCRIPT_DIR}/localrepo/"
cd "${SCRIPT_DIR}/localrepo"
repo-add localrepo.db.tar.xz tealinux-modularitea-libs-git-*.pkg.tar.zst

echo "==> [2.5/4] Registering localrepo in host pacman.conf for dependency resolution..."
# Add localrepo to host pacman.conf so makepkg can install tealinux-modularitea-libs-git
LOCALREPO_ENTRY="[localrepo]\nServer = file://${SCRIPT_DIR}/localrepo/\nSigLevel = Optional TrustAll"
if ! grep -q "\[localrepo\]" /etc/pacman.conf; then
    echo -e "\n${LOCALREPO_ENTRY}" | sudo tee -a /etc/pacman.conf > /dev/null
fi
sudo pacman -Sy --noconfirm
# Install the libs package so modularity's makepkg -s can resolve it
sudo pacman -S --noconfirm --needed tealinux-modularitea-libs-git

# Ensure localrepo is removed from host pacman.conf after this step
cleanup_host_pacman() {
    echo "==> Cleaning up localrepo from host pacman.conf..."
    sudo sed -i '/\[localrepo\]/,/^$/d' /etc/pacman.conf
}
trap cleanup_host_pacman EXIT

echo "==> [3/4] Building tealinux-modularity-git..."
cd "${SCRIPT_DIR}/localrepo/tealinux-modularity"
rm -f tealinux-modularity-git-*.pkg.tar.zst
makepkg -fs --noconfirm
# Copy to localrepo and add
cp tealinux-modularity-git-*.pkg.tar.zst "${SCRIPT_DIR}/localrepo/"
cd "${SCRIPT_DIR}/localrepo"
repo-add localrepo.db.tar.xz tealinux-modularity-git-*.pkg.tar.zst

# Cleanup host pacman.conf now (before ISO build) - disable trap
cleanup_host_pacman
trap - EXIT

echo "==> [4/4] Building ISO with mkarchiso..."
cd "${SCRIPT_DIR}"
sudo rm -rf .work
time sudo systemd-inhibit mkarchiso -r -v -w .work -o out tealinux

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

notify-send -u critical "Tealinux Build" "Selesai dalam ${elapsed_time} detik" || true
mpv notif.mp3 > /dev/null 2>&1 &

echo "==> Build selesai dalam ${elapsed_time} detik"
