#!/bin/sh

# build docker container from the latest openwrt rootfs

cleanup() {
    rm -rf "$workdir"
}

set -ex
trap cleanup EXIT
version=23.05.4
url=https://downloads.openwrt.org/releases/$version/targets/x86/64/openwrt-$version-x86-64-rootfs.tar.gz
image=koti/openwrt-rootfs:"$version"
workdir="$(mktemp -d)"
curl --silent "$url" | tar -xzf- -C "$workdir"
mkdir -p "$workdir"/var/lock
cat >"$workdir"/Dockerfile <<'EOF'
FROM scratch
COPY . /
RUN opkg update && opkg install iptables-zz-legacy bind-dig tcpdump
CMD ["/bin/sh"]
EOF
docker build --tag "$image" "$workdir"
#docker push "$image"
