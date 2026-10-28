#!/bin/sh
# Load stock DHCP functions without registering/running the stock protocol.
add_protocol() { :; }
. /lib/netifd/proto/dhcp.sh dhcpplus load
init_proto "$@"

proto_dhcpplus_init_config() {
    proto_dhcp_init_config
}

dhcpplus_generate_pair() {
    local random digest attempt
    for attempt in 1 2 3; do
        random=$(hexdump -n 4 -e '1/4 "%u"' /dev/urandom) || return 1
        case "$random" in ''|*[!0-9]*) return 1;; esac
        random=$((random & 2147483647))
        [ "$random" -ne 0 ] && break
    done
    [ "$random" -ne 0 ] || return 1
    fixedxid=$(printf '%08x' "$random") || return 1
    digest=$(printf '%s' "${random}LUIOITDCNNCMPVHP" | openssl dgst -sha1) || return 1
    digest=${digest##* }
    case "$digest" in ''|*[!0-9a-f]*) return 1;; esac
    [ "${#digest}" -eq 40 ] || return 1
    option60="00001f28$digest"
}

# This callback is used only by stock dhcp.sh in this protocol process.
# Drop legacy raw hostname options; only stock hostname= controls Option12.
# Drop all legacy Option60 aliases and emit the generated value exactly once.
proto_dhcp_add_sendopts() {
    local code hex is60=0
    code=$(printf '%s' "${1%%:*}" | tr 'A-Z' 'a-z')
    case "$code" in
        12|hostname) return 0;;
        60|vendor) is60=1;;
        0x*)
            hex=${code#0x}
            case "$hex" in ''|*[!0-9a-f]*) :;;
                *) [ "$((code))" -eq 12 ] && return 0
                   [ "$((code))" -eq 60 ] && is60=1;;
            esac;;
    esac
    if [ "$is60" = 1 ]; then
        [ "$1" = "0x3c:$option60" ] && [ "$option60_sent" = 0 ] || return 0
        option60_sent=1
    fi
    [ -n "$1" ] && append "$3" "-x $1"
    return 0
}

dhcpplus_set_options() {
    local type
    json_get_type type sendopts
    case "$type" in
        array) json_select sendopts;;
        '') json_add_array sendopts;;
        *) return 1;;
    esac
    json_add_string '' "0x3c:$option60"
    json_close_array
    # Suppress a legacy vendorid, which stock dhcp.sh would otherwise add again.
    json_add_string vendorid ''
}

proto_dhcpplus_setup() {
    local fixedxid option60 name value option60_sent=0
    if [ ! -r /usr/lib/iptv/udhcpc-xid.so ] || ! dhcpplus_generate_pair || ! dhcpplus_set_options; then
        proto_notify_error "$1" DHCPPLUS_GENERATION_FAILED
        proto_block_restart "$1"
        return 1
    fi
    # DHCP+ defaults; explicit interface settings always take precedence.
    for name in hostname sendclientid defaultreqopts classlessroute iface6rd reqopts; do
        json_get_var value "$name"
        [ -n "$value" ] && continue
        case "$name" in
            hostname) value='*';;
            sendclientid) value=none;;
            reqopts) value='1 3 6 12 15 28 31 33';;
            *) value=0;;
        esac
        json_add_string "$name" "$value"
    done
    proto_export "IPTV_FIXED_XID=$fixedxid"
    proto_export "LD_PRELOAD=/usr/lib/iptv/udhcpc-xid.so"
    proto_dhcp_setup "$@"
}

proto_dhcpplus_renew() { proto_dhcp_renew "$@"; }
proto_dhcpplus_teardown() { proto_dhcp_teardown "$@"; }
add_protocol dhcpplus
