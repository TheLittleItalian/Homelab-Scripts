#!/bin/bash
set -euo pipefail

# Directories #
BASE_DIR="$HOME/audits/system_snapshots"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
SNAP_DIR="$BASE_DIR/$TIMESTAMP"

mkdir -p "$SNAP_DIR"

log_cmd() {
	local name="$1"
	shift
	"$@" > "$SNAP_DIR/$name.txt" 2>&1
}

# System Identity #
log_cmd hostname hostnamectl
log_cmd uptime uptime

# Kernel/OS #
log_cmd kernel uname -a
log_cmd os_release cat /etc/os-release

# Services #
log_cmd running.services systemctl list-units --type=service --state=running
log_cmd enabled_services systemctl list-units --type=service

# Timers #
log_cmd timers systemctl list-timers --all --no-pager
if [ -n "$XDG_RUNTIME_DIR" ]; then
	log_cmd user_timers systemctl --user list-timers --all --no-pager
else 
	echo "User timers skipped: no active user session detected" > "$SNAP_DIR/user_timers.txt"
fi

# Network #
log_cmd ip_addr ip a
log_cmd ip_route ip routes
log_cmd nmcli nmcli device status

# Ports #
log_cmd listening_ports ss -tulpen

# SSH #
log_cmd ssh_status systemctl status sshd

# Users #
log_cmd user awk -F: '$7 !~ /nologin/ {print $1}' /etc/password

echo "Snapshot created at: $SNAP_DIR"
