#!/bin/bash

# Examples:
#	find_up.sh some_dir "foo*bar" -execdir pwd \;
#	find_up.sh . "uni_functions.sh"

set -e
path="$1"
shift 1
while [[ "$path" != "/" ]];
do
	find_result1=$(find $path -maxdepth 1 -mindepth 1 -type l -name "$@")
	find_result2=$(find $path -maxdepth 1 -mindepth 1 -type f -name "$@")
	#echo "$find_result1"
	#echo "$find_result2"

	if [ "$find_result1" != "" ]; then
		echo "$find_result1"
		break
	fi
	if [ "$find_result2" != "" ]; then
		echo "$find_result2"
		break
	fi

	path="$(readlink -f $path/..)"
done
