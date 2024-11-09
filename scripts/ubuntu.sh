#!/bin/sh

# Build Docker image for Ubuntu client.

cleanup() {
    rm -rf "$workdir"
}

set -ex
trap cleanup EXIT
image=koti/ubuntu-client:latest
workdir="$(mktemp -d)"
cat >"$workdir"/Dockerfile <<'EOF'
FROM docker.io/ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive && apt-get -qq update && apt-get -qq install -y iproute2 isc-dhcp-client bind9-utils dnsutils tcpdump chrony vim && rm -rf /var/cache/apt
CMD ["/bin/bash", "-l"]
EOF
docker build --tag "$image" "$workdir"
