#!/usr/bin/env bash
#
# Paste clipboard contents to stdin.
#
# Author: David Urbina (davidurbina.dev@gmail.com)
# Date: 2022-02
# License: MIT
# Updated: 2024-07
#
# -*- mode: shell-script -*-

set -uo pipefail

VERSION="v2.1.30"
app=${0##*/}

usage() {
	cat <<EOF
Usage: $app [options]

Pastes clipboard contents to stdin depending on the session type (Wayland or Xorg).

Options:
  -h, --help              Show this help message and exit.
  -v, --version           Show the version of this script and exit.
  -c, --check-version     Checks the version of this script against the remote repo version and prints a message on how to update.

Behavior:
- If running under Wayland, the script uses wl-paste to paste the clipboard contents.
- If running under Xorg, the script uses xclip to paste the clipboard contents.

Dependencies:
- wl-paste: Required for Wayland sessions.
- xclip: Required for Xorg sessions.

Examples:
  Paste the clipboard contents to stdin:
    $app

  Paste the clipboard contents to a file:
    $app > output.txt
EOF
}

version() {
	echo "$app version $VERSION"
}

check_version() {
	echo "[INFO] Current version: $VERSION"
	echo "[INFO] Checking for updates..."

	local remote_version
	remote_version="$(curl -s https://raw.githubusercontent.com/Diomeh/dsu/master/VERSION)"

	# strip leading and trailing whitespace
	remote_version="$(echo -e "${remote_version}" | tr -d '[:space:]')"

	# Check if the remote version is different from the local version
	if [[ "$remote_version" != "$VERSION" ]]; then
		echo "[INFO] A new version of $app ($remote_version) is available!"
		echo "[INFO] Refer to the repo README on how to update: https://github.com/Diomeh/dsu/blob/master/README.md"
	else
		echo "[INFO] You are running the latest version of $app."
	fi
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			-h | --help)
				usage
				exit 0
				;;
			-v | --version)
				version
				exit 0
				;;
			-c | --check-version)
				check_version
				exit 0
				;;
			*)
				echo "[ERROR] Unknown option: $1" >&2
				usage
				exit 1
				;;
		esac
	done
}

parse_args "$@"

# Determine if user is running Wayland or Xorg
if [[ "$XDG_SESSION_TYPE" = "wayland" ]]; then
	# Check if wl-paste is installed
	if ! command -v wl-paste >/dev/null; then
		echo "[ERROR] wl-paste is not installed" >&2
		exit 1
	fi

	# Paste clipboard contents to stdin
	wl-paste
elif [[ "$XDG_SESSION_TYPE" = "x11" ]]; then
	# Check if xclip is installed
	if ! command -v xclip >/dev/null; then
		echo "[ERROR] xclip is not installed" >&2
		exit 1
	fi

	# Paste clipboard contents to stdin
	xclip -o -sel clip
else
	echo "[ERROR] Unknown session type: $XDG_SESSION_TYPE" >&2
	exit 1
fi
