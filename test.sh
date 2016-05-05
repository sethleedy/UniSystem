#!/bin/bash

clear


# Load my Uni Functions script for some functions to use.
function load_uni_functions() {
	# use my custom functions
	uni_functions_path=$(./find_up.sh . "uni_functions.sh")
	#echo "uni: $uni_functions_path"
	test_true=false

	if [ "$uni_functions_path" != "" ]; then
		source "$uni_functions_path" #2>/dev/null

		if [ "$?" -ne 0 ]; then
			echo "Could not source the Uni System Functions (uni_functions.sh)"
			exit 12
		fi
	else
		echo "Could not find the file uni_functions.sh"
		exit 11
	fi

}

# Load my Uni Functions script for some functions to use.
echo "Loading Functions"
load_uni_functions

find_amount=10

	echo "9a of $find_amount"
	sslstrip_var=$(loc_file "sslstrip") # Find the file
	add_to_cache_loc_file "sslstrip" "$sslstrip_var" # Add it to the cache.
	#loc_file_in_cache=$(check_loc_file_cache "sslstrip") # See if it exists
	#echo "In cache: $loc_file_in_cache" # Test

	echo "$sslstrip_var"
	if [ "$sslstrip_var" == "" ] && [ "$USE_SSLSTRIP" == "yes" ]; then
		echo "Missing: sslstrip"
		exit 10
	fi

	echo "9b of $find_amount"
	sslstrip_var=$(loc_file "sslstrip")
	add_to_cache_loc_file "sslstrip" "$sslstrip_var"
	#loc_file_in_cache=$(check_loc_file_cache "sslstrip")
	#echo "In cache: $loc_file_in_cache" # Test

	echo "$sslstrip_var"
	if [ "$sslstrip_var" == "" ] && [ "$USE_SSLSTRIP" == "yes" ]; then
		echo "Missing: sslstrip"
		exit 10
	fi

	#echo " "
	#echo "In Array Key: "$in_array_key
	#echo "In Array Val: "$in_array_val
	#echo " "
	#echo "Test print Array Item: sslstrip -> "${cache_arr[sslstrip]}
	#echo "Test print Entire Array: "
		#for i in "${!cache_arr[@]}"
		#do
		  #echo "key  : $i"
		  #echo "value: ${cache_arr[$i]}"
		#done
	#echo "ALL: ${!cache_arr[@]}"

exit 0
