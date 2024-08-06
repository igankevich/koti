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
logread -e koti
dig +short igankevich.com
EOF
}

configure_sh() {
    cat >/root/.profile <<'EOF'
export PS1='router 🔥 '
EOF
    rm -f /etc/banner
    # password 'root'
    sed -i 's|^root::.*$|root:$1$MFhaa2d3$izzB9koiCjBSoqMbRsAni/:19940:0:99999:7:::|' /etc/shadow
}

configure_resolv_conf() {
    cat >/etc/resolv.conf <<'EOF'
nameserver 9.9.9.9
EOF
}

install_koti() {
    cp -r src/luci-app-koti/root/* /
    cp -r src/luci-app-koti/htdocs/* /www/
    /etc/init.d/koti enable
}

set -e
configure_network_devices
configure_default_route
configure_resolv_conf
configure_sh
install_koti
wait_for_br_lan
exec "$@"
