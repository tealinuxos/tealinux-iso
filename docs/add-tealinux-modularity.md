# Menambahkan tealinux-modularity ke ISO TealinuxOS

Panduan untuk menambahkan **tealinux-modularity** sebagai aplikasi bawaan di ISO TealinuxOS. Dokumen ini menjelaskan cara kerja sistem dan langkah-langkah reproduksi secara lengkap.

---

## Daftar Isi

- [Prasyarat](#prasyarat)
- [Gambaran Umum](#gambaran-umum)
- [Langkah-langkah](#langkah-langkah)
  - [1. Siapkan tealinux-modularitea-libs](#1-siapkan-tealinux-modularitea-libs)
  - [2. Siapkan tealinux-modularity](#2-siapkan-tealinux-modularity)
  - [3. Build Paket](#3-build-paket)
  - [4. Daftarkan Paket ke Localrepo](#4-daftarkan-paket-ke-localrepo)
  - [5. Tambahkan ke packages.x86_64](#5-tambahkan-ke-packagesx86_64)
  - [6. Build ISO](#6-build-iso)
- [Struktur File](#struktur-file)
- [Lokasi di ISO](#lokasi-di-iso)
- [Update Paket](#update-paket)
- [Troubleshooting](#troubleshooting)

---

## Prasyarat

Pastikan paket-paket berikut sudah terinstall di mesin build:

```bash
sudo pacman -S base-devel rust bun webkit2gtk-4.1 pkgconf glib2
```

---

## Gambaran Umum

ISO TealinuxOS menggunakan [`mkarchiso`](https://wiki.archlinux.org/title/Archiso) untuk membangun ISO. Paket custom ditambahkan melalui **local repository** (repo pacman lokal):

```
                  ┌──────────────────────────────────┐
                  │         localrepo/               │
                  │                                  │
                  │  *.pkg.tar.zst    localrepo.db   │
                  └──────────┬───────────────────────┘
                             │
                             ▼
┌─────────────────┐    ┌───────────┐    ┌──────────────┐
│ packages.x86_64 │───►│ mkarchiso │───►│  .iso output │
│ (daftar paket)  │    │           │    │              │
└─────────────────┘    └───────────┘    └──────────────┘
                             ▲
                             │
                  ┌──────────┴───────────────────────┐
                  │      tealinux/pacman.conf         │
                  │      [localrepo] = file://...     │
                  └──────────────────────────────────┘
```

tealinux-modularity terdiri dari **2 paket**:

| Paket | Deskripsi |
|-------|-----------|
| `tealinux-modularitea-libs-git` | Backend engine (CLI binaries: `modularitea-pacman`, `modularitea-grub`, dll.) |
| `tealinux-modularity-git` | Aplikasi GUI (Tauri + SvelteKit), depend pada libs di atas |

---

## Langkah-langkah

### 1. Siapkan tealinux-modularitea-libs

Clone/copy source `tealinux-modularitea-libs` ke folder localrepo:

```bash
cd tealinux-iso/localrepo/
git clone https://github.com/tealinuxos/tealinux-modularitea-libs.git
```

Buat file `PKGBUILD` di dalamnya (sudah tersedia):

```bash
# localrepo/tealinux-modularitea-libs/PKGBUILD
pkgname=tealinux-modularitea-libs-git
pkgver=1.0
pkgrel=1
pkgdesc="Headless backend engine for TealinuxOS Modularitea"
arch=('x86_64')
makedepends=('rust' 'cargo')

build() {
    cd "$startdir"
    export CARGO_TARGET_DIR=target
    cargo build --release
}

package() {
    cd "$startdir"
    install -Dm755 ./target/release/modularitea-pacman "$pkgdir/usr/bin/modularitea-pacman"
    install -Dm755 ./target/release/modularitea-grub "$pkgdir/usr/bin/modularitea-grub"
    install -Dm755 ./target/release/modularitea-settings "$pkgdir/usr/bin/modularitea-settings"
    install -Dm755 ./target/release/modularitea-systemctl "$pkgdir/usr/bin/modularitea-systemctl"
}
```

---

### 2. Siapkan tealinux-modularity

Buat folder `localrepo/tealinux-modularity/` dan buat `PKGBUILD`:

```bash
# localrepo/tealinux-modularity/PKGBUILD
pkgname=tealinux-modularity-git
pkgver=0.1
pkgrel=2
pkgdesc="TealinuxOS Modularity, written in Tauri|Rust|SvelteKit."
arch=("x86_64")
depends=("webkit2gtk-4.1")
makedepends=("rust" "bun")
source=(
    "tealinux-modularity::git+https://github.com/tealinuxos/tealinux-modularity.git#branch=development-harry"
    "${pkgname}.desktop"
)
sha256sums=('SKIP' 'SKIP')

build() {
    cd "${srcdir}/tealinux-modularity"

    # Copy modularitea-libs agar Cargo bisa resolve path dependency
    cp -r ${startdir}/../tealinux-modularitea-libs ${srcdir}/

    bun install
    bun run tauri build --no-bundle
}

package() {
    install -Dm755 \
        "${srcdir}/tealinux-modularity/src-tauri/target/release/tealinux-modularity" \
        "${pkgdir}/usr/bin/tealinux-modularity"
    install -D -m644 \
        ${pkgname}.desktop \
        ${pkgdir}/usr/share/applications/${pkgname}.desktop
}
```

> **Penting:** Saat `build()`, PKGBUILD meng-copy `tealinux-modularitea-libs` ke `$srcdir` karena
> `Cargo.toml` memiliki path dependency: `modularitea-libs = { path = "../../tealinux-modularitea-libs" }`.
> Dengan posisi copy ini, path `../../tealinux-modularitea-libs` dari folder `src-tauri/` resolve ke `$srcdir/tealinux-modularitea-libs`.

Buat file `.desktop` di `localrepo/`:

```ini
# localrepo/tealinux-modularity-git.desktop
[Desktop Entry]
Name=TealinuxOS Modularity
Categories=Settings
Exec=/usr/bin/tealinux-modularity
Icon=/usr/share/icons/tealinux-modularity.svg
Terminal=false
Type=Application
```

---

### 3. Build Paket

**Build tealinux-modularitea-libs dulu (dependency):**

```bash
cd localrepo/tealinux-modularitea-libs/
makepkg -fs
```

Hasil: `tealinux-modularitea-libs-git-1.0-1-x86_64.pkg.tar.zst`

```bash
# Pindahkan ke folder localrepo/
cp tealinux-modularitea-libs-git-*.pkg.tar.zst ../
```

**Build tealinux-modularity:**

```bash
cd localrepo/tealinux-modularity/
makepkg -fs
```

Hasil: `tealinux-modularity-git-0.1-2-x86_64.pkg.tar.zst`

```bash
cp tealinux-modularity-git-*.pkg.tar.zst ../
```

---

### 4. Daftarkan Paket ke Localrepo

```bash
cd localrepo/
repo-add localrepo.db.tar.xz tealinux-modularitea-libs-git-1.0-1-x86_64.pkg.tar.zst
repo-add localrepo.db.tar.xz tealinux-modularity-git-0.1-2-x86_64.pkg.tar.zst
```

Verifikasi:

```bash
tar -tvf localrepo.db.tar.xz | grep -E "tealinux-modula"
```

Output yang diharapkan:

```
drwxr-xr-x ... tealinux-modularitea-libs-git-1.0-1/
-rw-r--r-- ... tealinux-modularitea-libs-git-1.0-1/desc
drwxr-xr-x ... tealinux-modularity-git-0.1-2/
-rw-r--r-- ... tealinux-modularity-git-0.1-2/desc
```

---

### 5. Tambahkan ke packages.x86_64

Edit `tealinux/packages.x86_64` dan tambahkan kedua paket:

```diff
 # installer
 tealinux-installer-git
+tealinux-modularity-git
+tealinux-modularitea-libs-git
```

---

### 6. Build ISO

```bash
sudo bash build.sh
```

Script ini otomatis:
1. Update path `Server = file://...` di `pacman.conf` agar sesuai direktori saat ini
2. Hapus work directory lama
3. Jalankan `mkarchiso` → output ISO di folder `out/`

---

## Struktur File

```
tealinux-iso/
├── build.sh                           # Build ISO
├── tealinux/
│   ├── pacman.conf                    # [localrepo] terdaftar di sini
│   └── packages.x86_64               # Berisi: tealinux-modularity-git
│                                      #         tealinux-modularitea-libs-git
└── localrepo/
    ├── PKGBUILD                       # PKGBUILD tealinux-installer (existing)
    ├── tealinux-modularity/
    │   └── PKGBUILD                   # PKGBUILD tealinux-modularity-git
    ├── tealinux-modularitea-libs/
    │   └── PKGBUILD                   # PKGBUILD tealinux-modularitea-libs-git
    ├── tealinux-modularity-git.desktop
    ├── tealinux-modularity-git-0.1-2-x86_64.pkg.tar.zst
    ├── tealinux-modularitea-libs-git-1.0-1-x86_64.pkg.tar.zst
    └── localrepo.db.tar.xz           # Database repo lokal
```

---

## Lokasi di ISO

Setelah ISO dibangun, file-file berikut terinstall:

| File | Lokasi di ISO |
|------|--------------|
| Aplikasi GUI | `/usr/bin/tealinux-modularity` |
| Desktop entry | `/usr/share/applications/tealinux-modularity-git.desktop` |
| modularitea-pacman | `/usr/bin/modularitea-pacman` |
| modularitea-grub | `/usr/bin/modularitea-grub` |
| modularitea-settings | `/usr/bin/modularitea-settings` |
| modularitea-systemctl | `/usr/bin/modularitea-systemctl` |

Pengguna dapat menemukan **TealinuxOS Modularity** di menu aplikasi desktop.

---

## Update Paket

Untuk update tealinux-modularity saat ada perubahan source:

```bash
# 1. Update source
cd localrepo/tealinux-modularity/
# Edit PKGBUILD: naikkan pkgrel (misal: pkgrel=3)

# 2. Rebuild
makepkg -fs

# 3. Salin dan update database
cp tealinux-modularity-git-*.pkg.tar.zst ../
cd ..
repo-add localrepo.db.tar.xz tealinux-modularity-git-<versi-baru>.pkg.tar.zst

# 4. Rebuild ISO
cd ..
sudo bash build.sh
```

---

## Troubleshooting

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `Cannot find debugedit` | Debug package aktif | Tambahkan `options=(!debug)` di PKGBUILD |
| `pkg-config not found` | `pkgconf` belum terinstall | `sudo pacman -S pkgconf` |
| `modularitea-libs path not found` | Copy libs gagal | Pastikan `tealinux-modularitea-libs/` ada di `localrepo/` dan `cp -r` di `build()` benar |
| Package not found saat mkarchiso | Paket belum di-`repo-add` | Jalankan `repo-add localrepo.db.tar.xz *.pkg.tar.zst` |
| ISO build gagal: dependency unresolvable | Paket libs belum ada di packages.x86_64 | Tambahkan `tealinux-modularitea-libs-git` ke `packages.x86_64` |
