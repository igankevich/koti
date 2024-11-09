#!/bin/sh

run_dhclient() {
    umount /etc/resolv.conf
    ip address flush dev eth0
    ip route flush dev eth0
    dhclient eth0
}

configure_sh() {
    cat >>/root/.bash_profile <<'EOF'
export PS1='client 🔥 '
EOF
}

set -e
run_dhclient
configure_sh
exec "$@"
