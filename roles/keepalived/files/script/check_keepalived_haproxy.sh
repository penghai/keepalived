#!/bin/bash
DATE=`date '+%Y-%m-%d %T'`
SERVICE='haproxy'
CONF_FILE="/etc/keepalived/config/keepalived_${SERVICE}.conf"

CHECK_VIP()
{
    VIP_1=`cat $CONF_FILE | grep -v "#" | sed -n '/virtual_ipaddress/{n;p}' | grep [0-9][\.] | head -n 1 | tr -s " "`
    CHECKVIP_1=`ip a | grep $VIP_1`
    echo "## $DATE : [DEBUG] [CHECKVIP_1] $CHECKVIP_1"

    VIP_2=`cat $CONF_FILE | grep -v "#" | sed -n '/virtual_ipaddress/{n;p}' | grep [0-9][\.] | tail -n 1 | tr -s " "`
    CHECKVIP_2=`ip a | grep $VIP_2`
    echo "## $DATE : [DEBUG] [CHECKVIP_2] $CHECKVIP_2"
} >> /var/log/keepalived_${SERVICE}.log

CHECK_VIP

if [ "$VIP_1" != "$VIP_2" ];then
    if [[ -z "$CHECKVIP_1" && -n "$CHECKVIP_2" ]] || [[ -n "$CHECKVIP_1" && -z "$CHECKVIP_2" ]]; then
        echo "## $DATE : [WARN] Not all VIP on same node: Keepalived restart "
        systemctl restart keepalived_${SERVICE}.service
        exit 1
    fi
fi >> /var/log/keepalived_${SERVICE}.log
