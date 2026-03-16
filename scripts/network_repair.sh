#!/bin/bash
set -euo pipefail

LOG_DIR="$HOME/audits/network_repair"
LOG="$LOG_DIR/network_repair.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p "$LOG_DIR"

log() {
	echo "[$(date +'%H:%M:%S')] $1" >> "$LOG"
}

log "=== Network scan started ==="

# 1. Is NetworkManager running?
if ! systemctl is-active --quiet NetworkManager; then
	log "NetworkManager not running - restarting"
	systemctl restart NetworkManager
	sleep 3
fi

# 2. Is there an active connection?
if ! nmcli -t -f STATE general | grep -q connected; then
	log "Not connected - attempting reconnect"
	nmcli networking off
	sleep 2
	nmcli networking on
	sleep 5
fi

# 3. Do we have a default route?
if ! ip route | grep -q default; then
	log "No default route - restarting NetworkManager"
	systemctl restart NetworkManager
	sleep 5
fi

# 4. Internet reachability check
if ping -c 1 -W 2 8.8.8.8 >/dev/null; then
	log "Internet connectivity OK"
else
	log "Internet unreachable - retrying after reset"
	systemctl restart NetworkManager
	sleep 5
	
	if ping -c 1 -W 2 8.8.8.8 >/dev/null; then
		log "Connectivity restored"
	else
		log "Connectivity still failing - manual intervention required"
	fi
fi

log "=== Network scan completed ==="
