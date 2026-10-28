#!/bin/sh
set -eu
# APK_BUILD is an apk-tools 3.x binary with the mkpkg applet; not the system apk.
: "${APK_BUILD:?Set APK_BUILD to your packaging tool}"
: "${ROOTS:?Set ROOTS to the extracted package roots}"
: "${OUT:?Set OUT to the output directory}"
mkdir -p "$OUT"
"$APK_BUILD" mkpkg --compat 3.0.0 --files "$ROOTS/core" \
    --info name:netifd-proto-dhcpplus --info version:0.3.0-r2 \
    --info arch:x86_64 --info license:MIT \
    --info 'description:Automatic Liaoning Option60 for stock OpenWrt DHCP clients' \
    --info 'depends:libc busybox netifd openssl-util' \
    --output "$OUT/netifd-proto-dhcpplus-0.3.0-r2.apk"
"$APK_BUILD" mkpkg --compat 3.0.0 --files "$ROOTS/luci" \
    --info name:luci-proto-dhcpplus --info version:0.3.0-r3 \
    --info arch:noarch --info license:MIT \
    --info 'description:LuCI protocol UI for DHCP+ automatic authentication' \
    --info 'depends:luci-base netifd-proto-dhcpplus=0.3.0-r2' \
    --output "$OUT/luci-proto-dhcpplus-0.3.0-r3.apk"
