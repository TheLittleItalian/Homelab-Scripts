#!/usr/bin/env python3

import os
import subprocess
import datetime
import pathlib
import logging
import shutil

def setup_audit_dir():
	date_str = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
	audit_dir = pathlib.Path.home() / "audits" / "network_security" / date_str
	audit_dir.mkdir(parents=True, exist_ok=True)
	return audit_dir

def setup_report(audit_dir):
	report_path = audit_dir / "network_security.txt"
	return report_path

def write_section(report_path, title, content):
	with open(report_path, "a") as f:
		f.write(f"\n{title}\n")
		f.write("============\n")
		f.write(content)
		f.write("\n")

def run_command(command, use_sudo=False):
	if use_sudo:
		command = ["sudo"] + command
	try:
		result = subprocess.run(
			command,
			capture_output=True,
			text=True
		)
		return result.stdout if result.stdout else result.stderr
	except FileNotFoundError:
		return f"Command not found: {command[0]}\n"
	except Exception as e:
		return f"Error running command: {e}\n"

def command_exists(command):
	return shutil.which(command) is not None

def check_open_ports():
	return run_command(["ss", "-tulpn"])

def check_firewall():
	if command_exists("ufw"):
		return run_command(["ufw", "status", "verbose"], use_sudo=True)
	elif command_exists("iptables"):
		return run_command(["iptables", "-L", "-v", "-n"], use_sudo=True)
	elif command_exists("nft"):
		return run_command(["nft", "list", "ruleset"], use_sudo=True)
	else:
		return "No firewall command found.\n"

def check_connectivity():
	output = run_command(["ping", "-c", "10", "8.8.8.8"])
	output += "\n"
	if command_exists("dig"):
		output += run_command(["dig", "+short", "google.com"])
	else:
		output += run_command(["nslookup", "google.com"])
	return output

def check_failed_ssh():
	return run_command([
		"journalctl", "_COMM=sshd", "-p", "3",
		"--since", "24 hours ago"
	])

def main():
	audit_dir = setup_audit_dir()
	report_path = setup_report(audit_dir)

	date_str = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

	# Write header
	with open(report_path, "w") as f:
		f.write(f"Network & Security Audit - {date_str}\n")
		f.write("============\n")
	
	# Run each section
	write_section(report_path, "Open Ports:", check_open_ports())
	write_section(report_path, "Firewall Status:", check_firewall())
	write_section(report_path, "Connectivity Test (Ping & DNS):", check_connectivity())
	write_section(report_path, "Failed SSH Logins (last 24h):", check_failed_ssh())

	print(f"Audit Complete. Report saved to:\n{report_path}")
if __name__ == "__main__":
	main()
