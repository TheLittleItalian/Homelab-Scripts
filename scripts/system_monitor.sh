#!/bin/bash

# ====================
# System Resource & Service Monitor
# ====================

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="$HOME/audits/system_monitor/$DATE"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system_report.txt"

echo "System Resource & Service Monitor -$DATE" > "$LOG_FILE"
echo "====================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# --- CPU Usage ---

echo "CPU Usage:" >> "$LOG_FILE"
echo "--------" >> "$LOG_FILE"
CPU=$(top -bn1 | awk -F'[:, ]+' '/Cpu\(s\)/{usage=$2+$4; printf "%.1f", usage}')
echo "CPU Usage: $CPU%" >> "$LOG_FILE"
echo "CPU Usage: $CPU%" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# --- Memory Usage ---

echo "Memory Usage:" >> "$LOG_FILE"
echo "--------" >> "$LOG_FILE"
MEM=$(free -h | awk '/Mem:/ {print $3 " used / " $2 " total"}')
echo "Memory Usage: $MEM" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# --- Disk Usage ---

echo "Disk Usage (Root):" >> "$LOG_FILE"
echo "--------" >> "$LOG_FILE"
DISK=$(df -h / | awk 'NR==2 {print $3 " used / " $2 " total (" $5 " used)"}')
echo "Root Disk: $DISK" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# --- Swap Usage ---

echo "Swap Usage:" >> "$LOG_FILE"
echo "--------" >> "$LOG_FILE"
SWAP=$(free -h | awk '/Swap:/ {print $3 " used / " $2 " total "}')
echo "Swap: $SWAP" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# --- Service Check ---

echo "Critical Services Status:" >> "$LOG_FILE"
echo "--------------" >> "$LOG_FILE"
SERVICES=("sshd" "docker" "nginx")

for svc in "${SERVICES[@]}"; do
	if systemctl list-unit-files | grep -q "^$svc"; then
		if systemctl is-active --quiet $svc; then
			echo "$svc is running" >> "$LOG_FILE"
		else
			echo "$svc is NOT running" >> "$LOG_FILE"
		fi
	else
		echo "$svc is not installed" >> "$LOG_FILE"
	fi
done
echo >> "$LOG_FILE"

# --- Network Connectivity ---

echo "Network Connectivity:" >> "$LOG_FILE"
echo "--------------" >> "$LOG_FILE"
ping -c 10 8.8.8.8 >> "$LOG_FILE" 2>@1

echo "System monitoring complete. Logs saved to $LOG_FILE"
