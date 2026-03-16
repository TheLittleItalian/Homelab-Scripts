#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
AUDIT_DIR="$HOME/audits/system_audits/$DATE"
mkdir -p "$AUDIT_DIR"

echo "Starting system audit: $DATE"

pacman -Qqe > "$AUDIT_DIR/explicit-packages.txt"
pacman -Qq > "$AUDIT_DIR/all-packages.txt"
pacman -Qm > "$AUDIT_DIR/aur-packages.txt"
pacman -Qu > "$AUDIT_DIR/pending-updates.txt"

ORPHANS="$AUDIT_DIR/orphaned-packages.txt"
pacman -Qtdq > "$ORPHANS"

ORPHAN_PKGS=$(cat "$ORPHANS") 

if [ -n "$ORPHAN_PKGS" ]; then
	echo "Removing orphaned packages..." >> "$ORPHANS"
	sudo pacman -Rns --noconfirm $ORPHAN_PKGS >> "$ORPHANS" 2>&1
else
	echo "No orphaned packages found." >> "$ORPHANS"
fi

echo "Audit complete. Files saved in $AUDIT_DIR"
