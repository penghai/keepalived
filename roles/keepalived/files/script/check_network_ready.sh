#!/bin/bash
ip_gw=`ip route|grep "default via"|awk '{print $3}'`
if [ -n "$ip_gw" ];then
    ip_check=$ip_gw
    echo "Checking default gateway $ip_gw"
else
    ip_check='127.0.0.1'
    echo "No gateway was found! Checking 127.0.0.1 instead"
    echo "wait 15 seconds, ensure network is ready"
    sleep 15
fi
count=0
while true
do
    ret=`ping -c 3 $ip_check| grep "packets transmitted" | awk -F',' '{print $2}' | awk '{print $1}'`
    if [ $ret -eq 3 ]; then
        echo 'Network is ready'
        exit 0
    fi
    sleep 1
    let "count++"
    echo "Network is not ready, checking $count times"
done
exit 1
