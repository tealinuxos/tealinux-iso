#!/bin/bash

sudo sed -i "s|Server = file://.*|Server = file://$(pwd)/localrepo/|" ./tealinux/pacman.conf

start_time=$(date +%s)

LOCALREPO="$(pwd)/localrepo"


# --- tealinux-installer ---
if [[ ! -f "$LOCALREPO/tealinux-installer-git-2.0-1-x86_64.pkg.tar.zst" ]]; then
    cd ./tealinux-installer
    makepkg -fs
    mv tealinux-installer-git-2.0-1-x86_64.pkg.tar.zst "$LOCALREPO"
    cd ..
else
    echo "[SKIP] tealinux-installer already exists"
fi


# --- tealinux-modularity ---
if [[ ! -f "$LOCALREPO/tealinux-modularity-git-1.0-1-x86_64.pkg.tar.zst" ]]; then
    cd ./tealinux-modularitea
    makepkg -fs
    mv tealinux-modularity-git-1.0-1-x86_64.pkg.tar.zst "$LOCALREPO"
    cd ..
else
    echo "[SKIP] tealinux-modularity already exists"
fi

# --- modularitea-libs ---
if [[ ! -f "$LOCALREPO/modularitea-libs-1.0-1-x86_64.pkg.tar.zst" ]]; then
    git clone https://github.com/tealinuxos/tealinux-modularitea-libs.git
    cd tealinux-modularitea-libs
    makepkg -fs
    cp modularitea-libs-1.0-1-x86_64.pkg.tar.zst "$LOCALREPO"
    cd ..
else
    echo "[SKIP] modularitea-libs already exists"
fi

# --- hojicha ---
if [[ ! -f "$LOCALREPO/hojicha-ai-git-1.0-1-x86_64.pkg.tar.zst" ]]; then
    if [[ -d "hojicha-AI" ]]; then
        cd hojicha-AI
        git pull
        git switch openai
    else
        git clone https://github.com/tealinuxos/hojicha-AI.git
        cd hojicha-AI
        git switch openai
    fi
    makepkg -fs
    cp hojicha-ai-git-1.0-1-x86_64.pkg.tar.zst "$LOCALREPO"
    cd ..
else
    echo "[SKIP] hojicha-AI already exists"
fi


# --- hojicha-ai ---
if [[ -f "$LOCALREPO/hojicha-ai-git-1.0-1-x86_64.pkg.tar.zst" ]]; then
    cd hojicha-AI
    git pull
    cd ..
else
    git clone https://github.com/tealinuxos/hojicha-AI.git
fi

cd hojicha-AI
makepkg -fs
cp hojicha-ai-git-1.0-1-x86_64.pkg.tar.zst "$LOCALREPO"
cd ..


# --- repo-add ---
cd "$LOCALREPO"
repo-add localrepo.db.tar.xz \
    tealinux-installer-git-2.0-1-x86_64.pkg.tar.zst \
    tealinux-modularity-git-1.0-1-x86_64.pkg.tar.zst \
    modularitea-libs-1.0-1-x86_64.pkg.tar.zst \
    os-prober-btrfs-1.83-2-x86_64.pkg.tar.zst \
    paru-2.0.4-1-x86_64.pkg.tar.zst \
    hojicha-ai-git-1.0-1-x86_64.pkg.tar.zst

cd ..

# --- ISO build ---
sudo rm -rf .work
time sudo systemd-inhibit mkarchiso -r -v -w .work -o out tealinux

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

notify-send -u critical "Tealinux Build" "Exited. done in $elapsed_time seconds"
mpv notif.mp3 > /dev/null 2>&1 &