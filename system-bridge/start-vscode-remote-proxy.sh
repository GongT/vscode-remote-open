#!/usr/bin/bash

set -Eeuo pipefail
shopt -s lastpipe

declare -a LISTENING_SOCKETS SOCKET_FILES

function die() {
	echo "$*" >&2
	exit 1
}

function is_listen() {
	local I CHECK=$1
	for I in "${LISTENING_SOCKETS[@]}"; do
		if [[ $I == "$CHECK" ]]; then
			return 0
		fi
	done
	return 1
}

if [[ $UID -ne 0 ]]; then
	die "this script requires root privilege"
fi

ss --unix --socket=unix_stream --processes --listening | grep vscode-ipc | awk '{print $4}' | mapfile -t LISTENING_SOCKETS
find "/run/user" -mindepth 2 -maxdepth 2 -type s -name 'vscode-ipc-*.sock' | mapfile -t SOCKET_FILES

for SOCKET_FILE in "${SOCKET_FILES[@]}"; do
	if ! is_listen "$SOCKET_FILE"; then
		echo "delete ununsed socket: $SOCKET_FILE" >&2
		# unlink "$SOCKET_FILE"
	fi
done

if [[ ${#LISTENING_SOCKETS[@]} -gt 0 ]]; then
	echo "start proxyd to socket ${LISTENING_SOCKETS[0]}" >&2
	exec /usr/lib/systemd/systemd-socket-proxyd --exit-idle-time=10s "${LISTENING_SOCKETS[0]}"
else
	echo "no socket exists" >&2
	exit 233
fi
