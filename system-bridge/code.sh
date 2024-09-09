#!/usr/bin/env bash

set -Eeuo pipefail

if [[ ! ${SSH_CLIENT+exists} ]]; then
	echo "not ssh, try execute native vscode" >&2
	if [[ -e /usr/bin/code-insiders ]]; then
		exec /usr/bin/code-insiders "$@"
	fi
	if [[ -e /usr/bin/code ]]; then
		exec /usr/bin/code "$@"
	fi
	echo "failed find vscode" >&2
	exit 1
fi

if [[ ! ${VSCODE_IPC_HOOK_CLI+exists} ]]; then
	export VSCODE_IPC_HOOK_CLI=/run/vscode/vscode-remote.socket
fi

if ! [[ -e /run/vscode/binary ]]; then
	mkdir -p /run/vscode
	rm -f /run/vscode/binary

	find /proc -mindepth 2 -maxdepth 2 -name cmdline -print0 | while read -d '' -r CMDFILE; do
		if cat "$CMDFILE" | tr '\0' ' ' | grep -q -- 'out/server-main.*--start-server'; then
			BIN=$(cat "$CMDFILE" | awk -F '\0' '{print $1}')
			RBIN="$(dirname "$BIN")/bin/remote-cli"
			if [[ -e "$RBIN/code-insiders" ]]; then
				ln -s "$RBIN/code-insiders" /run/vscode/binary
				break
			elif [[ -e "$RBIN/code" ]]; then
				ln -s "$RBIN/code" /run/vscode/binary
				break
			fi
		fi
	done

	if ! [[ -e /run/vscode/binary ]]; then
		echo "failed find vscode remote cli" >&2
		exit 1
	fi
fi

exec "$(realpath /run/vscode/binary)" "$@"
