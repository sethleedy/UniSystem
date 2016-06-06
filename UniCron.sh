#!/bin/bash

# Loops every 60 seconds to check if something needs to be run.
# Emulates CronTab.

# Format for UniCronTab
#	/ The slash means OR. Machine2 OR @Group name in this location
#	"DateTime / @shortcut"	"Machine1,Machine2 / @Group" "Command1,Command2 / F:Function"
#	"@min"	"Node1,Node2"	"check_gmail.sh"
#	"@daily"	"@webservers"	"F:run_log_archiving"
#	"@hourly"	"node1,node2,@backupservers"	"F:remote_shutdown"

# Special group name: @local		This will simply execute the command on the local machine. Not a remote one and does not need to know the current machine name.

# Instead of the first five fields, one of eight special strings may appear:
#	Use leading zeros when using the numbers in UniCron
#	string         meaning
#	------         -------
#	@reboot        Run once, at startup.
#	@yearly        Run once a year, "0 0 1 1 *".
#	@annually      (same as @yearly)
#	@monthly       Run once a month, "0 0 1 * *".
#	@weekly        Run once a week, "0 0 * * 0".
#	@daily         Run once a day, "0 0 * * *".
#	@midnight      (same as @daily)
#	@hourly        Run once an hour, "0 * * * *".

# Normal CronTab Format:
#	Use leading zeros when using the numbers in UniCron
#	* * * * *
#	| | | | |
#	| | | | |
#	| | | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
#	| | | +------ Month of the Year (range: 01-12)
#	| | +-------- Day of the Month  (range: 01-31)
#	| +---------- Hour              (range: 0-23)
#	+------------ Minute            (range: 0-59)

# Date Time format:  date +"%Y/%m/%d %H:%M" = 2014/10/04 14:03 <-- 24 hour format only right now.
# Date optional. If the date is there, then the time is mandatory.
#	"2014/10/04 14:05"

source "UniCron_Functions.sh"

# Keep checking things and spawning the correct processes to handle them.
while true;
do

	# Check if shutting down or Restarting Uni System to apply script updates
	# Grab something here to check against.
	if [ "$" -eq 0 ]; then
			test_true=true
			break
	fi

	# We can load from a DB some stuff to check.


	# Hardcoded stuff below
		# Check gmail once a min.
		check_schedule("@min" "dev-lin" "check_gmail.sh")

		# Run every 20 mins the ip updater and nmap scanner
		check_schedule("20,40,0 * * * *" "@local" "update_ip.sh")

	# Loop as a daemon
	sleep 60
done
