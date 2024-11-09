#!/bin/sh

configure_wireguard() {
    ip link delete koti 2>/dev/null || true
    ip link add dev koti type wireguard
    ip link set dev koti up
    ip address add 10.0.0.1/32 dev koti
    ip route flush dev koti
    umask 0077
    wg genkey >/tmp/priv
    wg pubkey </tmp/priv >/tmp/pub
    wg setconf koti /dev/stdin << EOF
[Interface]
ListenPort = 7575
PrivateKey = $(cat /tmp/priv)
EOF
    printf "Public key: %s\n" "$(cat /tmp/pub)"
}

configure_sh() {
    cat >>/root/.bash_profile <<'EOF'
export PS1='forwarder 🔥 '
EOF
}

set -e
configure_wireguard
configure_sh
exec "$@"
