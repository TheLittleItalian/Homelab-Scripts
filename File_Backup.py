#!/usr/bin/env python3

import os
import sys
import shutil
import subprocess
import datetime
import pathlib
import logging
import argparse

def setup_directories(src_dir, dest_dir, log_dir):
	for directory in [src_dir, dest_dir, log_dir]:
		directory.mkdir(parents=True, exist_ok=True)

def setup_logging(log_dir):
	log_file = log_dir / "backup_log.txt"
	error_log_file = log_dir / "error_log.txt"

	# Main logger
	logger = logging.getLogger("backup")
	logger.setLevel(logging.DEBUG)

	# File handler for main log
	file_handler = logging.FileHandler(log_file)
	file_handler.setLevel(logging.INFO)
	file_handler.setFormatter(logging.Formatter("%(asctime)s - %(message)s"))

	# File handler for error log
	error_handler = logging.FileHandler(error_log_file)
	error_handler.setLevel(logging.ERROR)
	error_handler.setFormatter(logging.Formatter(
		"%(asctime)s - ERROR\nExit code:%(levelno)s\n%(message)s\n--------------------"
	))

	logger.addHandler(file_handler)
	logger.addHandler(error_handler)

	return logger, log_file

def get_file_info(file_path):
	file_name = file_path.name
	file_size = file_path.stat().st_size
	file_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	return file_name, file_size, file_date

def backup_file(file_path, dest_dir, logger):
	file_name, file_size, file_date = get_file_info(file_path)
	
	logger.info(f"Backing up {file_name}")
	logger.info(f"Size: {file_size} bytes | Timestamp: {file_date}")

	try:
		result = subprocess.run(
			["rsync", "-avcP", str(file_path), str(dest_dir) + "/"],
			capture_output=True,
			text=True
		)
		logger.info(result.stdout)
		if result.returncode != 0:
			logger.error(f"rsync failed for {file_name}:\n{result.stderr}")
	except Exception as e:
		logger.error(f"Error backing up {file_name}: {e}")
	
	logger.info("--------------------")

def backup_files(src_dir, dest_dir, logger):
	files = [f for f in src_dir.iterdir() if f.is_file()]
	
	if not files:
		logger.info("No files found in source directory.")
		return
	
	for file_path in files:
		backup_file(file_path, dest_dir, logger)

def format_duration(seconds):
	hours = seconds // 3600
	minutes = (seconds % 3600) // 60
	secs = seconds % 60
	return f"{hours:02d}:{minutes:02d}:{secs:02d}"

def parse_arguments():
	parser = argparse.ArgumentParser(description="Modular backup script")
	parser.add_argument(
		"--src",
		type=str,
		default=str(pathlib.Path.home() / "enter_dir_here"),
		help="Source directory to back up"
	)
	parser.add_argument(
		"--dest",
		type=str,
		default=str(pathlib.Path.home() / "enter_dir_here"),
		help="Destination directory for backup"
	)
	return parser.parse_args()

def main():
	args = parse_arguments()

	date_str = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

	src_dir = pathlib.Path(args.src)
	dest_dir = pathlib.Path(args.dest)
	log_dir = pathlib.Path.home() / "backup_logs" / date_str
	
	setup_directories(src_dir, dest_dir, log_dir)

	logger, log_file = setup_logging(log_dir)

	print(f"Begining backup - {date_str}. Please wait for confirmation before exiting.")
	logger.info(f"Backup Start - {date_str}")
	logger.info("====================")

	start_time = datetime.datetime.now()

	backup_files(src_dir, dest_dir, logger)

	end_time = datetime.datetime.now()
	duration = int((end_time - start_time).total_seconds())
	duration_str = format_duration(duration)

	logger.info(f"Backup complete. Duration: {duration_str} (hh:mm:ss)")
	print(f"Backup complete. Find log at {log_file}")

if __name__ == "__main__":
	main()
