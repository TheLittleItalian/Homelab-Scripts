# Homelab-Scripts
Homelab scripts for learning and documentation purposes.

## Scripts

### File_Backup.sh
A simple, yet modular and easily deployable script that allows for easy data backups. Rsync was opted for, over cp, to allow for checksum and file integrity checks. Also removes the "physical" copying and pasting of potentially integral files. Logs are kept, and their destination path is easily configurable.

### check-updates.sh
A script written to automate the rolling updates of my own personal system, not an automation process to be used at business nor enterprise scale as it relies on voluntary assumption of risk, and required sudo rules to circumvent manual intervention. Allows for the automation of Garuda-specific update commands, as well as Flatpak. The original script had utilized sudo pacman -S, with NOPASSWD rules employed on my system for pacman commands, but Garuda would request the use of garuda-update during every instance (the outcome was the same, automated updates) so I changed it for my specific system. Logs are kept, and can be easily configured or reconfigured. This is automated via systemd timers and services, running on system startup and giving a visual prompt via kdialog if updates were installed.

### disk_health.sh
A simple disk monitoring script to test and report disk operability and performance. Also checks SMART attributes. Logs are kept, and can be configured. 

### game-qos.sh
A script written to address connectivity issues I was experiencing in online gaming. It's desired effect is to set priority to the UDP ports commonly used by Steam/Proton, while flushing any rules setting priorty elsewhere prior to giving priority to Steam/Proton.

### network_repair.sh
Written to automatically scan and detect network connectivity issues on my system. The script runs through a series of tests, checking connection status throughout, and will close when connectivity is restored. If no connection is made, the script will prompt for manual intervention.

### network_security_audit.s
Runs through a series of network checks, listing; open ports, firewall status and any applicable rules, network ping via Google, and any failed SSH attempts within the last 24 hours. Written, primarily, for learning and precautionary purposes.

### scripts_snapshot.sh
A script showcasing the modularity of the File_Backup.sh script, used specifically to create backups of all of my current scripts. Used primarily before making any major changes to important scripts, such as the check-updates.sh script or the File_Backup.sh script itself. 

### system_audit.sh
A script used to quickly view and compare pacman-compatible packages, saved in a specified audit directory. As of March 15, 2026, this does not include Flatpak contents - which will be added to address that.

### system_monitor.sh
A broad system check that details critical system components such as; CPU usage, SWAP usage, Memory usage. Disk usage, and checks the status of both critical system services as well as a ping test to ensure network operability. One of my older scripts, before writing scripts dedicated to these functions in greater detail.

### system_snapshot.sh
Used to capture a current snapshot of the system, logging things such as; Kernel/OS, running services and system timers, network ip address and device status, listening ports, SSH status, and the users registered on the system. As with almost every other script, the results are logged and their destination can be configured to preference.
