#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
AUDIT_DIR="$HOME/audits/disk_health/$DATE"
mkdir -p "$AUDIT_DIR"

REPORT="$AUDIT_DIR/disk_health_report.txt"

echo "Disk Health Audit - $DATE" > "$REPORT"
echo "==================================" >> "$REPORT"
echo >> "$REPORT"

DISKS=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')

for DISK in $DISKS; do
	echo "Checking $DISK" >> "$REPORT"
	echo "------------------------------" >> "$REPORT"
	# drive identity
	sudo smartctl -i "$DISK" >> "$REPORT"
	echo >> "$REPORT"
	# Key SMART attributes (filtered)
	sudo smartctl -A "$DISK" | grep -E \
		"Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable|Temperature|Power_On_Hours" \
		>> "$REPORT"
	echo >> "$REPORT"
done

echo "Audit complete. Report saved to:"
echo "$REPORT"
