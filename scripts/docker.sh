#!/bin/sh

cleanup() {
    do_cleanup >/dev/null 2>&1
}

do_cleanup() {
    set +e
    docker kill "$container"
    docker container rm "$container"
    docker network rm "$lan" "$wan"
    set -e
}

set -e
lan=koti-lan
wan=koti-wan
lan_subnet=10.107.0.0/16
wan_subnet=10.75.0.0/16
container=koti
openwrt_version=23.05.4
image=koti/openwrt-rootfs:"$openwrt_version"
case "$1" in
client)
    exec docker run \
        --rm \
        --cap-add NET_ADMIN \
        --cap-add SYS_ADMIN \
        --cap-add SYS_TIME \
        --security-opt seccomp=unconfined \
        --network "$lan" \
        --ip 10.107.1.2 \
        --name "$container"-client \
        --volume "$PWD":/src \
        --entrypoint /src/scripts/docker-entrypoint-client.sh \
        -it \
        "$image" \
        /bin/sh -l
    ;;
router | *)
    cleanup
    trap cleanup EXIT
    docker network create --subnet="$lan_subnet" "$lan" >/dev/null
    docker network create --subnet="$wan_subnet" "$wan" >/dev/null
    mkdir -p .root
    docker create \
        --rm \
        --cap-add NET_ADMIN \
        --cap-add SYS_ADMIN \
        --cap-add SYS_TIME \
        --security-opt seccomp=unconfined \
        --network "$lan" \
        --ip 10.107.1.1 \
        --name "$container" \
        --volume "$PWD":/src \
        --entrypoint /src/scripts/docker-entrypoint-router.sh \
        "$image" \
        /sbin/init \
        >/dev/null
    docker network connect --ip 10.75.1.1 "$wan" "$container"
    docker start "$container" >/dev/null
    exec docker exec -it "$container" /bin/sh -l
    ;;
esac
