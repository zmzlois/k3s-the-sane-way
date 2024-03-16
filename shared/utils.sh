#!/usr/bin/env bash

set -euo pipefail

checkFileForString() {
	# make sure the directory exists
	dirname "$2" | xargs mkdir -p
	if ! grep -sq "$1" "$2"; then
		echo "$1" >>"$2"
	fi
}

checkLineThenAppend() {

	# check if input file exists
	if [ ! -f "$1" ]; then
		echo "Error: Input file '$1' does not exist or is not a regular file...please provide '$1'" >&2
		exit 1
	fi

	if [ ! -w "$(dirname "$2")" ]; then
		echo "Error: Output directory '$2' is not writable...check permissions." >&2
		exit 1
	fi

	# Loop through each line in the input file
	while IFS = read -r line; do
		#check if the line exists in the output file

		if ! grep -Fxq "$line" "$2" >/dev/null 2>&1; then
			# Append the line to the output file if not already present
			echo "$line" >>"$2"
			echo "Line '$line' appended to '$2'."
		fi
	done <"$1"
}
