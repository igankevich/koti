#!/bin/sh

configure_network_devices() {
    rm -f /etc/board.d/99-default_network
    cat >/etc/board.d/99-z-docker <<'EOF'
. /lib/functions/uci-defaults.sh
board_config_update
ucidef_set_interface lan \
    device eth0 \
    protocol static \
    ipaddr 10.107.1.1 \
    netmask 255.255.0.0
ucidef_set_interface wan \
    device eth1 \
    protocol static \
    ipaddr 10.75.1.1 \
    netmask 255.255.0.0
board_config_flush
EOF
}

configure_default_route() {
    cat >/etc/uci-defaults/99-z-docker <<'EOF'
uci set network.wan.gateway=10.75.0.1
uci commit network
EOF
    ip route delete default || true
}

wait_for_br_lan() {
    mkdir -p /etc/profile.d
    cat >/etc/profile.d/99-wait-for-br-lan.sh <<'EOF'
while ! ip link show br-lan >/dev/null 2>/dev/null; do
    printf 'waiting for br-lan to appear...\n' >&2
    sleep 1
done
EOF
}

configure_sh() {
    cat >/root/.profile << 'EOF'
export PS1='router 🔥 '
EOF
    rm -f /etc/banner
    # silence "no password" warning
    sed -i 's/root::/root:*:/' /etc/shadow
}

set -e
configure_network_devices
configure_default_route
configure_sh
wait_for_br_lan
exec "$@"
