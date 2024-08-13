#!/bin/sh
set -e
endpoint="$(wg show koti endpoints | cut -f2)"
if test -z "$endpoint"; then
    exit 1
fi
port=7777
iptables -t nat -D PREROUTING -j koti 2>/dev/null || true
iptables -t nat -F koti 2>/dev/null || true
iptables -t nat -X koti 2>/dev/null || true
iptables -t nat -N koti
iptables -t nat -A koti -p udp --dport "$port" -j DNAT --to-destination "$endpoint"
iptables -t nat -A PREROUTING -j koti
