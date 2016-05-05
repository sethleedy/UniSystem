#!/bin/bash

# Always update the IPs and some other data.
# Helps me find my machines from afar.

# Get the Hostname and convert to lower case for scripting sakes.
lhostname="$HOSTNAME"
curr_host=${lhostname,,}

# Load my Uni Functions script for some functions to use.
function load_uni_functions() {
	# use my custom functions
	uni_functions_path=$(./find_up.sh . "uni_functions.sh")
	test_true="false"
	source "${uni_functions_path}" 2>/dev/null
	if [ "$?" -eq 0 ]; then
		test_true="true"
	fi

	if [ "$test_true" == "false" ]; then
		echo "Could not source the Uni System Functions (uni_functions.sh)"
		exit
	fi
}
load_uni_functions

# Make default to echo or not to screen
be_quiet=false
rm_command=$(loc_file "rm")
LOG_FILE_DIR="network_results/"
LOG_FILE="${LOG_FILE_DIR}${curr_host}_op.log"
#echo "LOG: "$LOG_FILE
$rm_command -f "${LOG_FILE_DIR}$LOG_FILE"

# Get the First network card MAC for filenames that are different.
#host_mac=

# Spit some date stamped machine details into the log
log_and_echo "#################" ${LOG_FILE}
cur_date=$(date)
log_and_echo "# ${cur_date}" ${LOG_FILE}
log_and_echo "# Our hostname is: ${curr_host}" ${LOG_FILE}
log_and_echo "#################" ${LOG_FILE}


# Write raw info of network to file.
# Need to check and use the other commands in case these are not installed.
# Check for 'ip addr'
ip_addr_command=$(loc_file "ip" "/sbin")
if [ "$ip_addr_command" != "" ]; then
	$ip_addr_command addr show > "${LOG_FILE_DIR}${curr_host}_ip_info.txt"
fi
ifconfig_command=$(loc_file "ifconfig" "/sbin")
if [ "$ifconfig_command" != "" ]; then
	$ifconfig_command > "${LOG_FILE_DIR}${curr_host}_ip_info.txt"
fi
route_command=$(loc_file "route" "/sbin")
$route_command -n > "${LOG_FILE_DIR}${curr_host}route_info.txt"

# Get IPs of system and write it out to file and array.
# Array
if [ "$ifconfig_command" != "" ]; then
	index=0;for ip in $($ifconfig_command | grep "[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}" | awk -F: '{ print $2 }' | awk '{ print $1 }'); do ip_arr[$((index++))]=$ip; done

	if [ ! $be_quiet ]; then
		echo "IPs: ${ip_arr[@]}"
	fi
	# File
	echo "IPs: ${ip_arr[@]}" > "${LOG_FILE_DIR}${curr_host}_ip_list.txt"
fi
if [ "$ip_addr_command" != "" ] && [ "$ifconfig_command" == "" ]; then
	index=0;for ip in $($ip_addr_command addr show | grep "[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}" | awk -F' ' '{ print $2 }'); do ip_arr[$((index++))]=$ip; done

	if [ ! $be_quiet ]; then
		echo "IPs: ${ip_arr[@]}"
	fi
	# File
	echo "IPs: ${ip_arr[@]}" > "${LOG_FILE_DIR}${curr_host}_ip_list.txt"
fi

## See what our INTERNET IP(s ?) is and write it out too.
# May bork due to no internet access or remote host not working.
	# Check if it returns something, then echo it. I don't want to lose the old file date stamp.
	ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
	if [ "$ext_ip" != "" ]; then
		#echo "$ext_ip"
		echo "$ext_ip" > "${LOG_FILE_DIR}${curr_host}_internet_ip.txt"
	fi



##
# Do the following modules if DB says to do so.
# Per machine optional here.
##

## NMapping the networks
# Loop the IPs Array and nmap some ip ranges.
	nmap_command=$(loc_file "nmap")

	# Remove the old file so we can update it with new information.
	$rm_command -f "${LOG_FILE_DIR}${curr_host}_ssh_scan.txt"

	if [ "$nmap_command" != "" ]; then
		log_and_echo "NMap: Starting..." ${LOG_FILE}
		for p in "${ip_arr[@]}"
		do
			# Ignoring the nmapping of 127.0.0 local addresses.
			if [ $(echo ${p} | cut -d "." -f 1) != "127" ]; then
				ip_range=$(echo ${p} | cut -d "." -f 1-3)
				#ip_range=${ip_range}".0"

				# Scan for open port SSH 22
				# Need to grab ports for the machine from DB
				# Each machine can have a different set of ports to scan for and options to use.
				log_and_echo "NMap: range: ${ip_range}" ${LOG_FILE}
				$nmap_command -T4 --open -sV -F -oG "${LOG_FILE_DIR}${curr_host}_SCANNING_on_${ip_range}.txt" ${ip_range}.*

			else
				echo "NMap: Skipping Local Network Address range: ${p}"
			fi
		done
	fi

