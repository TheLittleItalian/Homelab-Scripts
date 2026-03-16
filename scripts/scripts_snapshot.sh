#!/bin/bash
set -euo pipefail

# Functions

error_handler() {
	local exit_code=$?
	local line_no=$LINENO
	local cmd="$BASH_COMMAND"
	local timestamp
	timestamp=$(date +"%Y-%m-%d %H:%M:%S")
	{
		echo "ERROR occurred at $timestamp"
		echo "Exit code: $exit_code"
		echo "Line number: $line_no"
		echo "Command: $cmd"
		echo "----------------------"
	} >> "$ERROR_LOG_FILE"
}

# Directories
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
SRC_DIR="$HOME/scripts/"
DEST_DIR="$HOME/scripts_snapshots/$DATE"
LOG_DIR="$HOME/backup_logs/$DATE"
mkdir -p "$LOG_DIR"
mkdir -p "$SRC_DIR"
mkdir -p "$DEST_DIR"
LOG_FILE="$LOG_DIR/backup_log.txt"
ERROR_LOG_FILE="$LOG_DIR/error_log.txt"

# Traps

trap error_handler ERR


echo "Beginning backup - $DATE. Please wait for confirmation before exiting."
echo "Backup Start - $DATE" > "$LOG_FILE"
echo "=======================" >> "$LOG_FILE"

SCRIPT_START=$(date +%s)

shopt -s dotglob

for file in "$SRC_DIR"*; do
	if [ -f "$file" ]; then
		FILE_NAME=$(basename "$file")
		FILE_SIZE=$(stat -c%s "$file")
		FILE_DATE=$(date +"%Y-%m-%d %H:%M:%S")

		echo "Backing up $FILE_NAME" >> "$LOG_FILE"
		echo "Size: $FILE_SIZE bytes | Timestamp: $FILE_DATE" >> "$LOG_FILE"

		rsync -avcP "$file" "$DEST_DIR/" >> "$LOG_FILE" 2>&1

		echo "------------------------" >> "$LOG_FILE"
	fi
done

SCRIPT_END=$(date +%s)
DURATION=$((SCRIPT_END - SCRIPT_START))
printf "Backup complete. Duration: %02d:%02d:%02d (hh:mm:ss)\n" \
	$((DURATION/3600)) \
	$((DURATION%3600/60))\
	$((DURATION%60)) >> "$LOG_FILE"
echo "Backup complete. Find log at $LOG_FILE"
