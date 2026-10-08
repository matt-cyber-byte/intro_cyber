#!/bin/bash

set -euo pipefail

if (( EUID != 0 )); then
	echo "Run this script as root: sudo /bin/bash create_user.sh [username ...]" >&2
	exit 1
fi

if (( $# == 0 )); then
	read -r -p "Username to create: " username
	set -- "$username"
fi

for username in "$@"; do
	if [[ ! $username =~ ^[a-z_][a-z0-9_-]*\$?$ ]]; then
		echo "Invalid username: $username" >&2
		exit 1
	fi

	if getent passwd "$username" >/dev/null; then
		echo "User already exists: $username" >&2
		continue
	fi

	useradd --create-home --shell /bin/bash "$username"
	echo "Created user '$username'. Set a password now."
	passwd "$username"
done

echo "Current contents of /etc/passwd:"
cat /etc/passwd
