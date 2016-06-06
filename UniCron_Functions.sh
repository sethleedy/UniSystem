#!/bin/bash

# This is simply going to hold all the functions related to UniCron.

# String matching
# Returns if found or not.
# Call function, string to find and then, pass string to search.
# Use like; str_check=$(substring "wep.cap" "$file_name")
function substring() {
    reqsubstr="$1"
    shift
    string="$@"
    if [ -z "${string##*$reqsubstr*}" ]; then
        #echo "String '$string' contain substring: '$reqsubstr'.";
        return 0
    else
        #echo "String '$string' don't contain substring: '$reqsubstr'."
        return 1
    fi

    return 1
}

# Main Function to check if we are running the UniCron command or not, based on the conditions specified.
function check_schedule() {

	# $1 is the schedule. Need to parse this out correctly.....
	checking_schedule="$1"
	# $2 is the list of machines. Can be a mix of machine names and groups. Groups are defined in [???] and are themselves a list of machines.
	checking_machinelist="$2"
	# $3 is the list of commands to run or bash script functions. Can also be a mix of commands/functions.
	checking_commandlist="$3"

	OIFS=$IFS;
	IFS=",";

	exec_enabled="false"
	cur_date=$(date +"%Y/%m/%d")
	cur_time=$(date +"%H:%M")
	cur_date_time=$(date +"%Y/%m/%d %H:%M")
	cur_min=$(date +"%M")
	cur_hourly=$(date +"%H")
	cur_dayofweek=$(date +%-u)
	cur_dayofmonth=$(date +%e)
	cur_monthofyear=$(date +%m)
#	echo "${cur_date}"
#	echo "${cur_time}"
#	echo "${cur_date_time}"
#	echo "${cur_min}"
#	echo "${cur_hourly}"
#	echo "${cur_dayofweek}"
#	echo "${cur_dayofmonth}"
#	echo "${cur_monthofyear}"

	# Parse out the numbers and *'s
	checking_schedule_min=$(echo "$checking_schedule" | cut -d " " -f 1)
	checking_schedule_hourly=$(echo "$checking_schedule" | cut -d " " -f 2)
	# If the first field is a shortcut item { @min }, then all others have to be ignored. Do this by setting them to a *.
	if $(substring "@" "$checking_schedule_min"); then # Means there is a @shortcut code within.
		#echo "Shortcut: $checking_schedule_min"
		checking_schedule_hourly="*"
		checking_schedule_dayofmonth="*"
		checking_schedule_monthofyear="*"
		checking_schedule_dayofweek="*"
	elif $(substring "/" "$checking_schedule_min") && $(substring ":" "$checking_schedule_hourly"); then # Means there is a Date & Time Code within. EG: 2014/10/04 14:03
		#echo "DATE/TIME: $checking_schedule_min $checking_schedule_hourly"
		#exit

		if $(substring "$cur_date" "$checking_schedule_min") && $(substring "$cur_time" "$checking_schedule_hourly"); then
			exec_enabled="true"
		fi

	elif $(substring ":" "$checking_schedule_min"); then # Means there is a Time Code within. EG: 14:03
		#echo "TIME: $checking_schedule_min"
		#exit

		if $(substring "$cur_time" "$checking_schedule_hourly"); then
			exec_enabled="true"
		fi

	else
		checking_schedule_dayofmonth=$(echo "$checking_schedule" | cut -d " " -f 3)
		checking_schedule_monthofyear=$(echo "$checking_schedule" | cut -d " " -f 4)
		checking_schedule_dayofweek=$(echo "$checking_schedule" | cut -d " " -f 5)
	fi

	#echo "checking_schedule_min: $checking_schedule_min"
	#echo "checking_schedule_hourly: $checking_schedule_hourly"
	#echo "checking_schedule_dayofmonth: $checking_schedule_dayofmonth"
	#echo "checking_schedule_monthofyear: $checking_schedule_monthofyear"
	#echo "checking_schedule_dayofweek: $checking_schedule_dayofweek"

	# See if everything matches the schedule we are checking against.
	# Loop the numbers if more than one listed. EG: 20,40,0 on the minutes.

	checking_schedule_min_Array=("$checking_schedule_min")
	for ((i=0; i<${#checking_schedule_min_Array[@]}; ++i)); # ${checking_schedule_min_Array[$i]}
	do
		#echo "${checking_schedule_min_Array[$i]}"
		if [ "${checking_schedule_min_Array[$i]}" == "${cur_min}" ] || [ "${checking_schedule_min_Array[$i]}" == "*" ] || [ "${checking_schedule_min_Array[$i]}" == "@min" ]; then
			min_checked="true"
			#echo "checking_schedule_min: TRUE!!"
			break
		else
			min_checked="false"
			#echo "False"
		fi
	done

	checking_schedule_hourly_Array=("$checking_schedule_hourly")
	for ((i=0; i<${#checking_schedule_hourly_Array[@]}; ++i)); # ${checking_schedule_hourly_Array[$i]}
	do
		#echo "Array Hourly: ${checking_schedule_hourly_Array[$i]}"
		if [ "${checking_schedule_hourly_Array[$i]}" == "${cur_hourly}" ] || [ "${checking_schedule_hourly_Array[$i]}" == "*" ] || [ "${checking_schedule_hourly_Array[$i]}" == "@hourly" ]; then
			hourly_checked="true"
			#echo "checking_schedule_hourly: TRUE!!"
			break
		else
			hourly_checked="false"
			#echo "False"
		fi
	done

	checking_schedule_dayofmonth_Array=("$checking_schedule_dayofmonth")
	for ((i=0; i<${#checking_schedule_dayofmonth_Array[@]}; ++i)); # ${checking_schedule_dayofmonth_Array[$i]}
	do
		#echo "Day of Month Array: ${checking_schedule_dayofmonth_Array[$i]}"
		if [ "${checking_schedule_dayofmonth_Array[$i]}" == "${cur_dayofmonth}" ] || [ "${checking_schedule_dayofmonth_Array[$i]}" == "*" ] || [[ "${checking_schedule_dayofmonth_Array[$i]}" == "@monthly" && "${cur_dayofmonth}" == 1 ]]; then
			dayofmonth_checked="true"
			#echo "checking_schedule_dayofmonth: TRUE!!"
			break
		else
			dayofmonth_checked="false"
			#echo "False"
		fi
	done

	checking_schedule_monthofyear_Array=("$checking_schedule_monthofyear")
	for ((i=0; i<${#checking_schedule_monthofyear_Array[@]}; ++i)); # ${checking_schedule_monthofyear_Array[$i]}
	do
		#echo "Month of Year Array: ${checking_schedule_monthofyear_Array[$i]}"
		if [ "${checking_schedule_monthofyear_Array[$i]}" == "${cur_monthofyear}" ] || [ "${checking_schedule_monthofyear_Array[$i]}" == "*" ]; then
			monthofyear_checked="true"
			#echo "checking_schedule_monthofyear: TRUE!!"
			break
		else
			monthofyear_checked="false"
			#echo "False"
		fi
	done

	checking_schedule_dayofweek_Array=("$checking_schedule_dayofweek")
	for ((i=0; i<${#checking_schedule_dayofweek_Array[@]}; ++i)); # ${checking_schedule_dayofweek_Array[$i]}
	do
		#echo "Day of Week Array: ${checking_schedule_dayofweek_Array[$i]}"
		if [ "${checking_schedule_dayofweek_Array[$i]}" == "${cur_dayofweek}" ] || [ "${checking_schedule_dayofweek_Array[$i]}" == "*" ] || [[ "${checking_schedule_dayofweek_Array[$i]}" == "@weekly" && "${cur_dayofweek}" == 7 ]]; then # "${cur_dayofweek}" == 7 Because 7 = Sunday, the start of the week. Monday = 1.
			dayofweek_checked="true"
			#echo "checking_schedule_dayofweek: TRUE!!"
			break
		else
			dayofweek_checked="false"
			#echo "False"
		fi
	done


	# Revert to whatever it was before I took it over.
	IFS=$OIFS

	# Test Conditions
	if [ "$min_checked" == "true" ] && [ "$hourly_checked" == "true" ] && [ "$dayofmonth_checked" == "true" ] && [ "$monthofyear_checked" == "true" ] && [  "$dayofweek_checked" == "true" ]; then
		exec_enabled="true"
	fi

	# Make sure @machine(s) and @group(s) are set and then make sure the command(s) or function(s) is ready.
	# Then pass the command(s) into the database for dispersal through the network.
	#		OR SSH the commands to the machines directly for execution.
	#		OR if it is a local command, execute it within local shell.
	if [ "$exec_enabled"="true" ]; then
		echo "Tested TRUE"

		# Check and see if this command is for this machine or another on the network, OR BOTH.
		# if @local OR name is same as this machine -> Execute
		# if machine name is located in the @group passed to us -> Execute

			# Loop all the commands in the variable. Execute each one in the array.
			checking_commandlist_Array=("$checking_commandlist")
			for ((i=0; i<${#checking_commandlist_Array[@]}; ++i));
			do
				# Call function to execute the command.
				if fn_exists $i; then
					echo "Executing Function"
					${$i}

				fi

				# If it is a valid file to execute, do that command.

				# Get return status of execution

				# Log it.

			done

		return 0
	else
		echo "Not true. Not running."
		return 1
	fi

	# Return result of 0 if no errors.
}


# Call for testing
#check_schedule "20,40,0 * * * *"
#check_schedule "@min * * * *"
#check_schedule "2014/11/05 11:47"
#check_schedule "14:31"

#currr_date=$(date +"%Y/%m/%d %H:%M")
#check_schedule "$currr_date"
