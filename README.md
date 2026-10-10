
# Simple Antivirus - OS Lab 2

## 1. Project Overview

This project is a simple antivirus system developed using Bash shell scripts on Ubuntu Linux.

The antivirus monitors a directory for changes and checks files for suspicious extensions or malicious keywords.

When a malicious file is detected, it is copied to a quarantine directory and removed from the original directory.

The project also includes a restore tool that allows users to restore or permanently delete quarantined files.

Two bonus features are implemented:
- Cron Job: Runs an automatic antivirus scan at scheduled times.
- Whitelist: Prevents restored false-positive files from being quarantined again.

## 2. Project Structure

```text
9627-lab2/
├── antivirusd.sh
├── restore.sh
├── antivirus-cron.sh
├── Makefile
├── README.md
├── whitelist.txt
├── directory/
└── malicious_directory/
```

File descriptions:

- antivirusd.sh: Monitors the directory and detects malicious files.
- restore.sh: Allows users to restore or permanently delete quarantined files.
- antivirus-cron.sh: Performs an automatic antivirus scan using Cron.
- Makefile: Provides commands to run the antivirus and restore tool.
- README.md: Contains project documentation and instructions.
- whitelist.txt: Stores filenames restored as false positives.
- directory/: Contains files monitored by the antivirus.
- malicious_directory/: Stores quarantined files.

The antivirus also generates directory-info.last and directory-info.new to compare directory states during monitoring.

## 3. Prerequisites

The project requires:
- Ubuntu Linux
- Bash
- Standard Linux commands such as ls, cp, rm, grep, cmp, and mkdir
- Make
- Cron for the scheduling bonus

To install the required packages:

```bash
sudo apt update
sudo apt install bash coreutils grep make cron
```

## 4. Running the Antivirus

Open the terminal and navigate to the project directory:

```bash
cd ~/9627-lab2
```

Run the antivirus:

```bash
make
```

Or run the script directly:

```bash
./antivirusd.sh directory malicious_directory 5
```

The three arguments are:

1. directory: The directory to monitor.
2. malicious_directory: The quarantine directory.
3. 5: The checking interval in seconds.

The antivirus scans the directory immediately and then checks for changes every 5 seconds.

To stop the antivirus, press Ctrl+C.

To change the interval:

```bash
make time=10
```

## 5. Malicious File Detection

The antivirus detects suspicious files using two rules.

### Suspicious Extensions

The following extensions are considered suspicious:

- .exe
- .bat
- .vbs
- .scr
- .ps1

Only the final file extension is checked.

For example:
- file.txt.scr is suspicious.
- file.scr.txt is not suspicious based on its extension.
- file.exec is not suspicious based on its extension.

### Suspicious Keywords

The antivirus searches file contents for these keywords:

- virus
- trojan
- malware
- worm
- ransomware

The search uses grep -Eqi and is case-insensitive.

A file is considered malicious if it matches either a suspicious extension or a malicious keyword.

## 6. Quarantine

When a malicious file is detected:

1. The antivirus copies the file to malicious_directory.
2. It displays a warning message.
3. It removes the original file from directory.

The quarantined file remains available for review using restore.sh.

## 7. Restoring Files

Stop the antivirus before running the restore tool.

Run:

```bash
make restore
```

Or:

```bash
./restore.sh directory malicious_directory
```

The restore tool displays a numbered list of quarantined files.

After selecting a file, the user can choose:

1. Restore the file to the monitored directory.
2. Permanently delete the file from quarantine.
3. Go back to the file list.

The restore menu continues until the quarantine directory is empty or the user stops the program.

Restoring a file also adds its filename to whitelist.txt.

## 8. Makefile

The Makefile provides these commands:

- make: Starts the antivirus.
- make antivirus: Starts the antivirus explicitly.
- make restore: Starts the restore tool.
- make setup: Creates the quarantine directory if it does not exist.

The Makefile uses three variables:

- main_dir = directory
- quarantine_dir = malicious_directory
- time = 5

## 9. Testing

The antivirus was tested using normal and suspicious files.

Examples:

- normal.txt: Not detected when it contains no suspicious keywords.
- game.exe: Detected because of its extension.
- test.txt: Detected when its contents contain virus.
- file.txt.scr: Detected because the final extension is .scr.
- file.scr.txt: Not detected by extension alone.
- file.exec: Not detected by extension alone.
- uppercase.txt: Detected when its contents contain uppercase malicious keywords.

Additional tests included:

- Creating suspicious files while the antivirus was running.
- Restoring quarantined files.
- Permanently deleting quarantined files.
- Using the Go Back option.
- Checking the whitelist after restoring files.
- Restarting the antivirus to verify whitelist persistence.
- Testing the automatic Cron scanner.

The scripts were also checked using:

```bash
bash -n antivirusd.sh
bash -n restore.sh
bash -n antivirus-cron.sh
```

The Makefile commands were checked using:

```bash
make -n
make -n restore
```

## 10. Bonus 1: Cron Job

The antivirus-cron.sh script scans the monitored directory automatically without running an infinite loop.

The script changes to its own project directory before scanning, so it can use the correct relative file paths.

It also checks the whitelist before scanning files.

### Installing and Starting Cron

```bash
sudo apt install cron
sudo systemctl enable --now cron
```

Make the script executable:

```bash
chmod +x antivirus-cron.sh
```

### Scheduling an Automatic Scan

Open the Cron editor:

```bash
crontab -e
```

Add this line to run the script every minute:

```cron
* * * * * /bin/bash /home/vboxuser/9627-lab2/antivirus-cron.sh >> /home/vboxuser/9627-lab2/cron.log 2>&1
```

Save the file and exit.

Verify the schedule:

```bash
crontab -l
```

Cron starts the script every minute.

The script uses sleep 23, so scanning begins approximately 23 seconds after the scheduled start.

Scan output is saved to cron.log.

To remove the schedule, run crontab -e and delete the entry.

### Third Friday Scheduling Example

To schedule the script for the third Friday of every month at approximately 12:31:23 AM, use:

```cron
31 0 15-21 * * [ "$(date +\%u)" -eq 5 ] && /bin/bash /home/vboxuser/9627-lab2/antivirus-cron.sh
```

The day range 15-21 represents the third week of the month.

The condition checks whether the current day is Friday.

The script then waits 23 seconds before scanning.

This is an alternative schedule to the every-minute example.

## 11. Bonus 2: Whitelist

The whitelist feature prevents files restored as false positives from being quarantined repeatedly.

The whitelist is stored in:

```text
whitelist.txt
```

When a user selects option 1 in restore.sh, the restored filename is automatically added to whitelist.txt.

Before scanning each file, antivirusd.sh checks whether its filename exists in the whitelist.

If the filename is found, the antivirus skips that file even if it contains a suspicious extension or keyword.

The whitelist is persistent because it is saved in a text file.

The antivirus-cron.sh script also respects the whitelist.

### Example

Suppose file.txt.scr is detected as malicious and moved to quarantine.

The user runs:

```bash
make restore
```

The user selects file.txt.scr and chooses option 1.

The file is restored to directory and its filename is added to whitelist.txt.

When the antivirus scans again, it skips file.txt.scr because its filename is whitelisted.

## 12. Notes

- The antivirus is a basic educational project, not a replacement for real antivirus software.
- Suspicious files are identified using predefined extensions and keywords.
- The whitelist is based on filenames rather than file hashes.
- Directory monitoring compares saved ls -l output and may not detect every possible file-content change.
- The Cron scanner performs a single scan each time it is scheduled.
- The normal antivirus uses a continuous monitoring loop.

