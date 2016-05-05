#!/bin/bash

clear

# Load my Uni Functions script for some functions to use.
function load_uni_functions() {
	# use my custom functions
	uni_functions_path=$(../find_up.sh . -name "uni_functions.sh")
	test_true=false
	source "$uni_functions_path" 2>/dev/null
	if [ "$?" -eq 0 ]; then
		test_true=true
	fi

	if [ "$test_true" = false ]; then
		echo "Could not source the Uni System Functions (uni_functions.sh)"
		exit
	fi
}
echo "Loading Functions"
load_uni_functions

rm_command=$(loc_file "rm")
echo "rm: $rm_command"
