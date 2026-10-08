#!/bin/bash

set -u

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

delete_user() {
  local user="$1"

  if ! id "$user" >/dev/null 2>&1; then
    echo "User '$user' does not exist."
    return 0
  fi

  if ! userdel -r "$user" >/dev/null 2>&1; then
    echo "Failed to delete user '$user'." >&2
    return 1
  fi

  echo "Deleted user: $user"
}

if [[ $# -gt 0 ]]; then
  for user in "$@"; do
    delete_user "$user" || exit 1
  done
else
  while IFS=: read -r username _ uid _; do
    [[ -z "$username" ]] && continue
    [[ "$username" == "root" ]] && continue

    if (( uid >= 1000 )); then
      delete_user "$username" || exit 1
    fi
  done < /etc/passwd
fi

cat /etc/passwd
