#!/bin/sh
# Run on a Linux x86_64 build host. Never run against the router filesystem.
set -eu
cd "$(dirname "$0")/.."
: "${SIGNING_KEY:?Set SIGNING_KEY to the private PEM file}"
mkdir -p build/downloads build/toolchain build/apk dist/openwrt-25.12/x86_64
tc=openwrt-toolchain-25.12.4-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst
curl --fail --location --retry 3 "https://downloads.openwrt.org/releases/25.12.4/targets/x86/64/$tc" -o "build/downloads/$tc"
echo "4a106d523ad673d827c397bef8bd70e0ec2d9ff1e5ecfd0e79f346f90195c90e  build/downloads/$tc" | sha256sum -c -
curl --fail --location --retry 3 https://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/apk-tools-static-3.0.8-r0.apk -o build/downloads/apk-tools.apk
echo '673f1bfb22136fc42ca035321cf731a4ad0452c000928666cb39a138f0c277bf  build/downloads/apk-tools.apk' | sha256sum -c -
tar --zstd -xf "build/downloads/$tc" -C build/toolchain --strip-components=1
tar -xzf build/downloads/apk-tools.apk -C build/apk sbin/apk.static
cc=$(find "$PWD/build/toolchain" -type f -name 'x86_64-openwrt-linux-musl-gcc' -print -quit)
test -n "$cc"
export STAGING_DIR="$PWD/build/toolchain"
"$cc" -Os -shared -fPIC -Wall -Wextra -Werror -o build/udhcpc-xid.so package/netifd-proto-dhcpplus/src/udhcpc-xid.c
python3 tools/stage.py --helper build/udhcpc-xid.so
export APK_BUILD="$PWD/build/apk/sbin/apk.static"
export ROOTS="$PWD/build/roots"
export OUT="$PWD/dist/openwrt-25.12/x86_64"
sh tools/mkpkg.sh
openssl pkey -in "$SIGNING_KEY" -pubout -out build/derived-public.pem
cmp keys/dhcpplus-public.pem build/derived-public.pem
"$APK_BUILD" adbsign --sign-key "$SIGNING_KEY" "$OUT"/*.apk
"$APK_BUILD" mkndx --sign-key "$SIGNING_KEY" --description 'DHCP+ for OpenWrt 25.12 x86_64' --pkgname-spec '${name}-${version}.apk' --output "$OUT/Packages.adb" "$OUT"/*.apk
"$APK_BUILD" --keys-dir "$PWD/keys" verify "$OUT"/*.apk "$OUT/Packages.adb"
mkdir -p build/no-keys
if "$APK_BUILD" --keys-dir "$PWD/build/no-keys" verify "$OUT/Packages.adb"; then
    echo 'ERROR: unsigned trust test unexpectedly passed' >&2
    exit 1
fi
cp keys/dhcpplus-public.pem "$OUT/"
cp docs/feed.html dist/index.html
touch dist/.nojekyll
(cd "$OUT" && sha256sum *.apk Packages.adb dhcpplus-public.pem > SHA256SUMS)
