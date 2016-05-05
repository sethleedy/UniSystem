#!/bin/bash

# Version .2

# This daemon is meant to check on startup and start and monitor and loop through all things concerning the Uni System


# This called with & will background the script. Then we kill off the parent for automatic daemonizing.
function daemonize() {
	###
	# Functions
	###

	## use my custom functions
	uni_functions_path=$(./find_up.sh . -name "uni_functions.sh")

	test_true=false

	source "$uni_functions_path" 2>/dev/null
	if [ "$?" -eq 0 ]; then
		test_true=true
	fi

	if [ "$test_true" = false ]; then
		echo "Could not source the Uni System Functions (uni_functions.sh)"
		exit
	fi


	# Fire this function when the script is told to shutdown with the EXIT signal
	# Allows a safe shutdown
	trap uni_system_shutdown EXIT

	# First verify all required programs are installed and check for correct ones to use in case of duplicates
	# Basic requirements - BTSync, ?tinc(VPN)?, white_hat directory, ssh
	#	Install if not included, Run and wait on white_hat directory to finish syncing to get all the files and configurations.
	#		check configurations of above systems

	# Nice optional configs and programs - check temp on all devices that support it,
	#

	# Device specific for certain duties - besside-ng and other cracking tools,
	#	Install if not included
	#		check configurations of above systems



	# Set all variables to be in use

	# Start programs and maybe wait for them to settle down
		# Start Uni System Cron or otherwise called UniCron
		# UniCron will also start programs on its own. Modeled after CronTab syntax with the addition of a field labeling the set of machines for it to run on.

		# Also, make sure programs from previous run are running or not by pulling the PIDs from the DB and checking.
		#If not running, run them newly.


	# UniSystem Online. Don't bother reloading. Needs to be exported for other processes to know this.
	unisystem_program_online="true"


	# Start watch for .cap transfers
	# Move to module when I can....
	mon_convert_caps=$(loc_file "convert_caps_for_uploading.sh" "/home/seth/white_hat")
	$mon_convert_caps &
	echo "$mon_convert_caps" > /home/seth/unisystem/mon.txt
	echo "$!" >> /home/seth/unisystem/mon.txt

	# Keep checking things and spawning the correct processes to handle them.
	while true;
	do

		# Check if shutting down or Restarting Uni System to apply script updates


		# Loop as a daemon
		sleep 2
	done

} # End Daemonize function.


# Change to script directory
cd ${0%/*} >/dev/null 2>&1 </dev/null

# Daemonize ?
#daemonize &
daemonize
#kill $$ # Kill parent, leave child running
exit 0
