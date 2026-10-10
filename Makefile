main_dir = directory
quarantine_dir = malicious_directory
time = 5

.PHONY: all setup antivirus restore

all: antivirus

setup:
	mkdir -p $(quarantine_dir)

antivirus: setup
	bash antivirusd.sh $(main_dir) $(quarantine_dir) $(time)

restore: setup
	bash restore.sh $(main_dir) $(quarantine_dir)
