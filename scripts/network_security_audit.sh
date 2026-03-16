#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
AUDIT_DIR="$HOME/audits/network_security/$DATE"
mkdir -p "$AUDIT_DIR"

REPORT="$AUDIT_DIR/network_security.txt"

echo "Network & Security Audit - $DATE" > "$REPORT"
echo "=================" >> "$REPORT"
echo >> "$REPORT"

echo "Open Ports:" >> "$REPORT"
echo "=================" >> "$REPORT"
ss -tuln >> "$REPORT"
echo >> "$REPORT"

echo "Firewall Status:" >> "$REPORT"
echo "=================" >> "$REPORT"

if command -v ufw >/dev/null 2>&1; then
	sudo ufw status verbose >> "$REPORT"
elif command -v iptables >/dev/null 2>&1; then
	sudo iptables -L -v -n >> "$REPORT"
elif command -v nft >/dev/null 2>&1; then 
	sudo nft list ruleset >> "$REPORT"
else
	echo "No firewall command found." >> "$REPORT"
fi
echo >> "$REPORT"

echo "Connectivity Test (Ping & DNS):" >> "$REPORT"
echo "=================" >> "$REPORT"

ping -c 10 8.8.8.8 >> "$REPORT" 2>&1
echo >> "$REPORT"

if command -v dig >/dev/null 2>&1; then
	dig +short google.com >> "$REPORT"
else
	nslookup google.com >> "$REPORT"
fi
echo >> "$REPORT"

echo "Failed SSH Logins (last 24h):" >> "$REPORT"
echo "=================" >> "$REPORT"
journalctl _COMM=sshd -p 3 --since "24 hours ago" >> "$REPORT" 2>/dev/null
echo >> "$REPORT"

echo "Audit Complete. Report saved to:"
echo "$REPORT"
