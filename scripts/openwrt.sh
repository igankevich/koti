#!/bin/sh

# Build Docker image from the specified OpenWRT rootfs.

cleanup() {
    rm -rf "$workdir"
}

set -ex
trap cleanup EXIT
version=23.05.4
url=https://downloads.openwrt.org/releases/$version/targets/x86/64/openwrt-$version-x86-64-rootfs.tar.gz
image=koti/openwrt-rootfs:"$version"
workdir="$(mktemp -d)"
curl --silent --fail --location "$url" | tar -xzf- -C "$workdir"
mkdir -p "$workdir"/var/lock
cat >"$workdir"/Dockerfile <<'EOF'
FROM scratch
COPY . /
RUN opkg update && opkg install iptables iptables-zz-legacy bind-dig tcpdump vim-fuller luci rsync unbound-daemon
CMD ["/bin/sh"]
EOF
docker build --tag "$image" "$workdir"
