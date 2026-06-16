# Tealinux Cosmic

# how to build

```sh
sudo pacman -Syu archiso git base-devel
```

then
```sh
git clone git@github.com:tealinuxos/tealinux-iso.git tealinux-cosmic
cd tealinux-cosmic
git submodule update --init tealinux/grub/lorem-loader
git submodule update --init tealinux/airootfs/usr/share/grub/themes/lorem-loader
```

finally
```sh
sh ./build_with_installer.sh
```

it will took about 30 mins average, based on how fast your computer + network.

# questions
```txt
q: how do I need modify behavior of an OS when I at live-iso's?
a: check out `airootfs` folder

q: build is too slow for me
a: sorry for that, but you can try ajust `/tealinux/profiledef.sh`, look at zstd stuff
```