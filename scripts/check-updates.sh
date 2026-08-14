#!/bin/bash

set -e
set -o pipefail

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

LOG_DIR="$HOME/scripts/update_logs"
mkdir -p "$LOG_DIR"

DATE=$(date +%F)
PACMAN_LOG="$LOG_DIR/${DATE}_pacman_upgrades.txt"
FLATPAK_LOG="$LOG_DIR/${DATE}_flatpak_upgrades.txt"

# Ensure required dependencies are installed
REQUIRED_PKGS=(flatpak kdialog)
MISSING_PKGS=()

for pkg in "${REQUIRED_PKGS[@]}"; do
	if ! pacman -Qi "$pkg" &>/dev/null; then
		MISSING_PKGS+=("$pkg")
	fi
done

if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
	echo "Installing missing dependencies: ${MISSING_PKGS[*]}"
	sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
fi

UPDATED=false

# Refresh package database quietly
# sudo pacman -Sy --quiet

# Count available updates
UPDATES=$(checkupdates 2>/dev/null | wc -l) || true

if [ "$UPDATES" -gt 0 ]; then
	sudo /usr/bin/garuda-update --noconfirm | tee -a "$PACMAN_LOG"
	UPDATED=true
fi

flatpak update -y | tee -a "$FLATPAK_LOG"

if ! grep -q "^[0-9].* x .*" "$FLATPAK_LOG"; then
	UPDATED=true
fi

flatpak uninstall --unused -y >> "$FLATPAK_LOG" 2>&1

if [ "$UPDATED" = true ]; then
	kdialog --passivepopup \
	"System updates were installed. Check log for details." \
	30
fi
