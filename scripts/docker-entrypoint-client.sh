#!/bin/sh

configure_default_route() {
    ip route delete default
    ip route add default via 10.107.1.1
}

configure_opkg() {
    mkdir -p /var/lock
}

configure_sh() {
    cat >/root/.profile <<'EOF'
export PS1='client 🔥 '
EOF
    rm -f /etc/banner
    # silence "no password" warning
    sed -i 's/root::/root:*:/' /etc/shadow
}

set -e
configure_default_route
configure_opkg
configure_sh
exec "$@"
