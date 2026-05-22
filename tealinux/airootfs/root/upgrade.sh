#!/bin/bash
set -e


echo "upgrade.sh is running"
pacman -Syy --noconfirm
pacman -S --noconfirm webkit2gtk-4.1