#!/bin/sh
# Real jshn and crypto; no DHCP process or UCI writes.
# OpenWrt JSON getters legitimately return nonzero for absent optional fields.
. /usr/share/libubox/jshn.sh
. /lib/functions.sh
eval "$(sed -n '/^proto_dhcpplus_init_config()/,$p' "$1" | sed '/^add_protocol dhcpplus$/d')"
proto_export() { case "$1" in IPTV_FIXED_XID=*) observed_xid=${1#*=};; esac; }
proto_notify_error() { error="$2"; }
proto_block_restart() { :; }
proto_dhcp_setup() {
    invoked=1
    observed_opts=''
    json_for_each_item proto_dhcp_add_sendopts sendopts observed_opts
}
for mode in legacy empty absent; do
    case "$mode" in
    legacy) input='{"fixedxid":"deadbeef","vendorid":"legacy","sendopts":["60:00","0X003C:11","vendor:old","0xc:0102","12:0304","0X000C:0506","hostname:legacy","125:abcd"],"hostname":"*"}';;
    empty) input='{"sendopts":[]}';;
    absent) input='{}';;
    esac
    for n in 1 2 3; do
        json_load "$input"
        invoked=0
        proto_dhcpplus_setup test eth99 || exit 1
        [ "$invoked" = 1 ] || exit 1
        printf '%s %s %s\n' "$mode" "$observed_xid" "$observed_opts"
    done
done
openssl() { return 1; }
json_load '{}'
invoked=0
if proto_dhcpplus_setup test eth99; then exit 1; fi
[ "$invoked" = 0 ] && [ "$error" = DHCPPLUS_GENERATION_FAILED ] || exit 1
echo PASS_FAIL_CLOSED
