#!/usr/bin/env bash
# shellcheck disable=SC2034

# iso_edition="base"
iso_edition="cosmic"
# iso_edition="plasma"
iso_name="tealinux-lilya-${iso_edition}"
iso_label="TEALINUX_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Tea Linux <https://tealinuxos.org>"
iso_application="Tea Linux Lilya"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
# airootfs_image_type="erofs"
airootfs_image_type="squashfs"
# airootfs_image_tool_options=('-zlzma,109' -E 'ztailpacking,fragments,dedupe')

# Faster compression
# airootfs_image_tool_options=('-comp' 'zstd' '-b' '256K' '-Xcompression-level' '1')
# bootstrap_tarball_compression=(zstd -c -T0 --long -15)

# Very Fast compression
airootfs_image_tool_options=('-comp' 'zstd' '-b' '256K' '-Xcompression-level' '2')
bootstrap_tarball_compression=(zstd -c -T4 --long -1)

## Default compression (use this for prod system)
# airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
# bootstrap_tarball_compression=(zstd -c -T0 --long -19)

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/skel/Desktop/tealinux-installer-git.desktop"]="0:0:755"
  ["/etc/skel/Desktop/tealinux-modularity-git.desktop"]="0:0:755"
)
