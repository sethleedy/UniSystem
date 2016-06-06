#!/usr/bin/env bash

###
# Variables
###

	# Create Log file
	LOG_FILE="install-script.log"
	RAW_LOG_FILE="raw_install-script.log"

	# This script name.
	curr_basename=$(basename "$0")
	#echo $curr_basename

###
# Start of Functions
###

# This will log all commands that do not need interaction, to another log file. So we can see all the output of the commands later.
function log_command {
	#Redirections don't seem to work within my function log_command
	echo " " 1>>${RAW_LOG_FILE} 2>&1
	echo "Command: $1" 1>>${RAW_LOG_FILE} 2>&1
	$1 1>>${RAW_LOG_FILE} 2>&1
}

function log_command_and_echo {
	#Redirections don't seem to work within my function log_command
	echo " " 1>>${RAW_LOG_FILE} 2>&1
	echo "Command: $1" 1>>${RAW_LOG_FILE} 2>&1
	$1 1>>${RAW_LOG_FILE} 2>&1
	
	echo "$1"
}

# Utility to log all echos AND display to screen
function log_and_echo {

	echo "$1" >> "${LOG_FILE}"
	echo "$1" >> "${RAW_LOG_FILE}"
	echo "$1"

}

# After install/setup, before UniSystem takes over for further setup per group/node type, what needs to be executed/linked/checked ?
function after_install_sanity_check {

	## This should call another function that simply enables the service, no matter the type of system; systemd, init.d, etc.
	
	# If ubuntu distro:
	if [ "${system_distro}" == "ubuntu" ] ; then
		log_command "update-rc.d ssh enable"
	fi
	# If fedora distro:
	if [ "${system_distro}" == "fedora" ] ; then
		log_command "chkconfig network on"
		log_command "chkconfig sshd on"
	fi

}

# This will install the package passed on $1 or exit script as we need it to continue.
# This function is to try every way possiable to install the package, no matter the system or package manager type.
function install_package {
	
	# Check for package manager programs and use them if found.
	# else exit with message.

	$test_aptitude_package=$(loc_file "aptitude" "/usr/bin")
	if [ "$test_aptitude_package" != "" ]; then
		log_command "aptitude -yq install $1"
	else
		log_and_echo "Cannot install package $1. Exiting"
		exit
	fi
}

function update_system_packages {

	# If fedora distro with yum:
	if [ "${system_distro}" == "fedora" ] ; then
		log_command "yum -y update"
		log_command "yum -y upgrade"
	fi

	# If ubuntu distro with apt-get OR aptitude:
	if [ "${system_distro}" == "ubuntu" ] ; then
		log_command "aptitude -y update"
		log_command "aptitude -y upgrade"
	fi
	
	# If ubuntu distro with Snap:
	## Ubuntu is now switching over to another package manager in 16.04, "Snap" packages
	if [ "${system_distro}" == "ubuntu" ] ; then
		log_command "snap -y update"
		log_command "snap -y upgrade"
	fi
	
} # End update_system_packages


#!! move to a module !
# Setup the Personal User
function setup_personal_account {
  log_and_echo  " "
  log_and_echo  "Setting up the user account."
  log_command "useradd -m $normal_account_user"
  echo '${normal_account_user}:${normal_account_user_password}' | chpasswd
}

#!! move to a module !
# Setup root password
function setup_root_account {
  log_and_echo  " "
  log_and_echo  "Setting up the root account."
  echo 'root:${account_root_password}' | chpasswd
}

#!! move to a module !
# Forward all emails going to root to a email address
function setup_root_email_forwarding {
  log_and_echo  " "
  log_and_echo  "Setup .forward on root account to forward all root emails to my email address. (Requires sendmail)"

  echo $system_email_monitor > ~/.forward
  # .forward does not work if the ownership or permissions are wrong.
  chmod 0644 ~/.forward
}

# Setup some auto running scripts/programs on USER, .bash_profile and .bashrc
# "$1" carries the information to add to the file
#
# Information:
#What is a login or non-login shell?

#When you login (type username and password) via console, either sitting at the machine, or remotely via ssh: .bash_profile is executed to configure your shell before the initial command prompt.
#But, if you’ve already logged into your machine and open a new terminal window (xterm) inside Gnome or KDE, then .bashrc is executed before the window command prompt. .bashrc is also run when you start a new bash instance by typing /bin/bash in a terminal.
#Why two different files?

#Say, you’d like to print some lengthy diagnostic information about your machine each time you login (load average, memory usage, current users, etc). You only want to see it on login, so you only want to place this in your .bash_profile. If you put it in your .bashrc, you’d see it every time you open a new terminal window.
function setup_personal_account_bash_profile {
  log_and_echo  " "
  log_and_echo  "Setup .bash_profile to run once when logging in from console OR SSH."
  #Redirections don't seem to work within my function log_command
  touch /home/$account_user/.bash_profile
  chmod 644 /home/$account_user/.bash_profile
  echo "$1" >> /home/$account_user/.bash_profile
}
function setup_personal_account_bashrc {
  log_and_echo  " "
  log_and_echo  "Setup .bashrc to run things when opening any terminal, by Desktop, console, or SSH."
  #Redirections don't seem to work within my function log_command
  touch /home/$account_user/.bashrc
  chmod 644 /home/$account_user/.bashrc
  echo "$1" >> /home/$account_user/.bashrc
}

# Setup some auto running scripts/programs on ROOT, .bash_profile and .bashrc
# "$1" carries the information to add to the file
function setup_root_account_bash_profile {
  log_and_echo  " "
  log_and_echo  "Setup .bash_profile to run things when logging in."
	#Redirections don't seem to work within my function log_command
	echo "$1" >> /root/.bash_profile
}
function setup_root_account_bashrc {
  log_and_echo  " "
  log_and_echo  "Setup .bashrc to run things when logging in."
	#Redirections don't seem to work within my function log_command
	echo "$1" >> /root/.bashrc
}

# Fedora ?,16,? uses systemd to manage the runlevel. So, use this function to set it.
# multi-user
# graphical
function set_system_runlevel { ## Needs reworked !

	# If fedora distro:
	if [ "${system_distro}" == "fedora" ] ; then
		if [ "${system_runlevel}" == "2" ] ; then
			log_command "rm -f /etc/systemd/system/default.target"
			log_command "ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target"
		fi
		if [ "${system_runlevel}" == "3" ] ; then
			log_command "rm -f /etc/systemd/system/default.target"
			log_command "ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target"
		fi
		if [ "${system_runlevel}" == "5" ] ; then
			log_command "rm -f /etc/systemd/system/default.target"
			log_command "ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target"
		fi
	fi

	# If ubuntu distro:
	if [ "${system_distro}" == "ubuntu" ] ; then
		if [ "${system_runlevel}" == "2" ] ; then
			log_command "rm -f /etc/systemd/system/default.target"
			log_command "ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target"
		fi
		if [ "${system_runlevel}" == "5" ] ; then
			log_command "rm -f /etc/systemd/system/default.target"
			log_command "ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target"
		fi
	fi
}

# Find the location of a script and return the path + script
# Returns the first one found.
# Use like; rm_command=$(loc_file "rm")
# Will return the path and command to the variable "rm_command" and allow you to use it via $rm_command "File_to_delete"
# Optional Second Argument ( $2 ) is to be search paths, separated by spaces. Eg; rm_command=$(loc_file "rm" "/bin /sbin /usr/bin /usr/sbin")
function loc_file() {

	file_name="$1"
	file_name_search_path="$2"

	# Use Variable Variables to create a variable with the name of the $1 filename. Then later we can check to see if it exists(and was already setup) and so skip the search for it.


	loc_file_return=$(type "$file_name" 2>&1>/dev/null)
	if [ $? -eq 1 ] || [ "$loc_file_return" == "" ]; then
		# Pass as second arg a space separated list of paths to search within for $file_name arg.
		# I was doing just /, but it can be too slow...
		# Recommend as the default, all command paths. ". /home/seth/unisystem /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /etc/init.d ~ /"
		if [ "$file_name_search_path" == "" ]; then
			# Good default. Same directory as called from and all of the system. But SLOW!
			sec_arg=". /home/seth/unisystem /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /etc/init.d /"
			#sec_arg="/home/seth/unisystem ."
		else
			sec_arg="$file_name_search_path"
		fi

		for pathing in $sec_arg # note that $sec_arg must NOT be quoted here!
		do
			# Option: -ignore_readdir_race
			# If a file disappears after its name has been read from a directory but before find gets around to examining the file with stat, don't issue an error message. If you don't specify this option, an error message will be issued. This option can be useful in system scripts (cron scripts, for example) that examine areas of the filesystem that change frequently (mail queues, temporary directories, and so forth), because this scenario is common for those sorts of directories.
			#echo "PATHING: $pathing"

			loc_file_return=$(find $pathing -ignore_readdir_race \( -type f -name "$file_name" -not -iname ".*" -not -path "*/.*/*" \) 2>/dev/null)
			#echo "=1 $loc_file_return within $pathing"

			if [ "$loc_file_return" != "" ]; then
				#echo "Breaking"
				break
			fi
		done
	else
		# The following is what works in terminal, strange in script. In script the return does not have the (). So a different cut is required.
		#loc_file_return=$(type "$file_name" | cut -d " " -f 4 | cut -d "(" -f 2 | cut -d ")" -f 1)

		# The following works in script, but not terminal...(strange, different results).
		loc_file_return=$(type "$file_name" | cut -d " " -f 3)

		#echo "=2 $loc_file_return"
	fi
	echo "$loc_file_return"
}

# At end of Script, cleanup
function end_script_cleanup {

	# Back to btsync dir
	cd "$btsync_dir"

	log_and_echo " "
	log_and_echo "Cleaning up leftover files."

	# Remove downloaded files.
	log_command "rm -f $cleanup_script_files >/dev/null 2>&1"

	# Make sure it is all written to disk before rebooting.
	log_command "sync"

	# Back to btsync dir
	cd "$btsync_dir"

}

# Run this and put in all the different commands that need to be checked for existience and its location assigned.
# Uses loc_file function
function setupCommandVars { 
	
	rm_command=$(loc_file "rm") # Setup rm command
	bash_command=$(loc_file "bash" "/bin")
	
}

# If the file is not found, an exit of the program with a message about not finding the file is displayed
function find_or_exit { # $1 is the file to find
	
	located=$(loc_file "$1")
	if [ "$located" ]; then
		return "$located"
	else
		echo "-----------"
		echo "Could not find file: $1"
		echo "Exiting"
		exit
	fi
}

# If the program is not found, it will try installing it. If it cannot, an exit and message about the error is displayed.
function find_or_install { #1 is the program to find
	
	located=$(loc_file "$1")
	#echo " - $located - "
	if [ "$located" != "" ]; then
		return "$located"
	else
		# Installing missing program
		install_package "$1"
	fi
}

function display_help {
	echo ""
	echo "Help: "
	echo "	First argument is the type of modules to setup for this nodes initial state, in the UniSystem."
	echo "	Once it is online with UniSystem, we can change its purpose later."
	echo "	Example:"
	echo "		"$curr_basename" -install type1,type2,type3"
	echo "		"$curr_basename" -install basic,webMin,syncThing,dVpn"
}


###
# Start of Code Execution
###

#Run as root user
if [ "$UID" -ne "0" ] ; then
	echo "[$(date "+%F %T")] Warning: Some modules may require installing and running as root."
	#display_help
	#exit 67
fi

# Setup all variables
setupCommandVars

# Restart the Logs. Delete older ones.
$rm_command -f "${LOG_FILE}" >/dev/null 2>&1
$rm_command -f "${RAW_LOG_FILE}" >/dev/null 2>&1



# Read the command line starting arguments and apply to variables
# If we do not have arguments, display help.
if [ $# -eq 0 ]; then
	display_help
fi

# Create array to hold modules on the -install line
declare -a modules_to_install=()

# Loop all arguments
until [ -z "$1" ]; do
	#echo "$1"

	# No sense doing anything if just displaying help -h
	if [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
		output_help
	fi

	# retrieve all the modules listed after this " -install "
	if [ "$1" == "-install" ]; then
		shift
		# Loop to get modules until EOL of next argument with a dash.
		until [ -z "$1" ]; do
			modules_to_install=("${modules_to_install[@]}" "$1") # Add to array
			shift
			
			## If the current one is now another optional command "-something", then exit the loop
			word="$1"
			if [ ${word:0:1} == "-" ]; then
				break
			fi
		done		
	fi

	shift
done

## See what modules here
#echo "Modules: ${modules_to_install[@]}"
#exit

# Loop the modules and do each setup
for cur_module in "${modules_to_install[@]}"; do

	# Execute them
	#ls -l "../modules/$cur_module/module_$cur_module.sh"
	
	# The following is how to include other bash files ". /path/to/functions"
	#log_command_and_echo ". \"../modules/$cur_module/module_$cur_module.sh\""
	. "../modules/$cur_module/module_$cur_module.sh"
	
# Done Looping Modules
done

exit

	# This will create the ".forward" in the root account. /root/.forward
	# It will allow any emails going to root to be forwarded to the system_email_monitor email address.
	use_system_email_monitor=true
	system_email_monitor="webmaster@sethleedy.name"

	# What runlevel should this be ?
	system_runlevel="2" # 2 is normal on Ubuntu for multiuser, networking, graphical desktop
	system_runlevel="3" # 3 is normal on Fedora for multiuser, networking
	system_runlevel="5" # 5 is normal on Fedora for multiuser, networking, graphical desktop

	# What distro is this installing on ?
	# Default is Ubuntu. That is my dev platform.
	# Specfic tools are used only on specfic distros, yum for Fedora, aptitude for Ubuntu.
	# SET reveals the enviroment variables: desktop_session & gdmsession & session all set to "ubuntu". Is it this way on Fedora and others ?
	# Needs work!
	system_distro="ubuntu"
	if [ "$SESSION" == "ubuntu" ]; then
		system_distro="ubuntu"
	fi
	if [ "$SESSION" == "fedora" ]; then
		system_distro="fedora"
	fi
	# If lbuntu is completely the same as ubuntu, then the following is redundent.
	if [ "$SESSION" == "lbuntu" ]; then
		system_distro="ubuntu"
	fi



	# Is this a 64bit or 32bit ? What cpu type ?
	# Trying to auto detect. Could set manually.
	# Does ARM processors(Raspberry Pi) need something different ?
	if [ $HOSTTYPE == "x86_64" ] ; then
		cpubit=64
	elif [ $HOSTTYPE == "i686" ] ; then
		cpubit=32
	else
		# We presume you have a modern system.
		cpubit=64
	fi
	#cpubit=64
	#cpubit=32

# Check to see if we have everything we need to run the program. Check see if all needed programs exists on the system. Offer to download the needed ones.

	# Install List of programs:
	# Basic OS stuff for running !this script!.
	system_install_list_basic="tail multitail crontabs cron cronie awk cut grep wget nano less tar gzip bzip2 chpasswd util-linux"

	#Tools for Just the specfic distro. In theory, these will not be available if the distro is wrong. Yum only installs on Fedora and Aptitude on Ubuntu or Debian.
	# Because of this, the installer will always give a bad exit since not everything was installed..(Verify this please)
	system_distro_specific="yum-plugin-fastestmirror aptitude ntsysv chkconfig dpkg"

	# Your desired tools and programs for operating a stable node.
	# If the modules are correctly written, they will install any missing dependants for that module.
	system_install_list_tools="openssh-server openssh-client openssh-clients openssh-sftp-server ssh-import-id ssh-copy-id screen htop iotop iftop ntp ntpdate sendmail p7zip zip unzip 7-zip 7zip dkms mtr logwatch smartmontools logrotate iwconfig iw ip nmap sqlite3 chpasswd libpcap-dev"

# Set usernames and passwords and keys.
# Could be hard set or dynamicly set by UniSystem pattern
	# Your normal user account for all programs and remote access
	normal_account_user="seth"
	normal_account_user_password="userpassword"
	# Root Account
	account_root_password="rootpassword"
		# Create Accounts
		#setup_personal_account
		#setup_root_account
	# SSH Keys

	# SQL usernames and passwords

	# Use fail2ban ? Recommended!
	use_fail2ban=true

	# I am setting this to default so I can get installs done quicker.
	#You can set it so you do not have to do updates later.
	do_system_update=false

	# After this script runs, it would have downloaded some files.
	# List the files to rm -f after the script is done.
	cleanup_script_files=" google.repo*"

exit
	# Choose the way to link the UniSystem to system startup.
		# Manual link to runlevel or use function "set_system_runlevel"
		sudo ln -s $(pwd)/$curr_basename /etc/init.d/

		# If ubuntu distro:
		if [ "${system_distro}" == "ubuntu" ] ; then
			# Debian/Ubuntu based tool to add to runlevels
			sudo update-rc.d "$curr_basename" defaults
		fi

		# If fedora distro:
		if [ "${system_distro}" == "fedora" ] ; then
			# Fedora based tool to add to runlevels
			chkconfig "$curr_basename" on
		fi


# Now unroll or otherwise get a copy of the current UniSystem. Copy it to the proper path. Start the correct BTSync program.
# At this point, BTSync will run and keep things in sync file(s) wise. OS should be setup as needed. UniCron should be running as the last item to start.
# After reboot, UniSystem should start back up.
