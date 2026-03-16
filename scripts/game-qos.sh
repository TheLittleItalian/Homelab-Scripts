#!/bin/bash

# auto-detect primary interface with a LAN/WiFi IP
IFACE=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')

if [ -z "$IFACE" ]; then
	echo "No active network interface detected. Exiting."
	exit 1
fi

echo "Detected interface: $IFACE"

# Flush existing rules

sudo tc qdisc del dev $IFACE root 2>/dev/null

# create prio queue with 3 bands

sudo tc qdisc add dev $IFACE root handle 1: prio bands 3

# Prio all UDP ports commonly used by Steam/Proton

for PORT in {27000..27100}; do
	sudo tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 \
		match ip sport $PORT 0xffff flowid 1:1
	sudo tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 \
		match ip dport $PORT 0xffff flowid 1:1
done

echo "QoS applied on $IFACE for Steam / Proton UDP ports (27000-27100)"





