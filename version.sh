#!/bin/bash
# version.sh - Print out various system version information

echo_version() {
	echo "$(tput setf 2)$1$(tput sgr 0)$2"
}

ldd_vers="$(ldd --version | head -n 1)"

echo_version "kernel release: " "$(uname -r)"
echo_version "kernel version: " "$(uname -v)"
echo_version "libc version:   " "${ldd_vers#ldd }"
echo_version "distribution:   " "$(lsb_release -ds)"
