#!/bin/bash
# version.sh - Print out various system version information

while getopts ":c" opt; do
	case "$opt" in
		c)
			SET_COLOR=$(tput setf 2)
			CLR_COLOR=$(tput sgr 0)
			;;
	esac
done
	
echo_version() {
	echo "$SET_COLOR$1$CLR_COLOR$2"
}

ldd_vers="$(ldd --version | head -n 1)"

echo_version "kernel release: " "$(uname -r)"
echo_version "kernel version: " "$(uname -v)"
echo_version "libc version:   " "${ldd_vers#ldd }"
echo_version "distribution:   " "$(lsb_release -ds)"
