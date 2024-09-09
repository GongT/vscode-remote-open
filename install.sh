#!/usr/bin/env bash

set -Eeuo pipefail
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

if [[ $UID -ne 0 ]]; then
	echo "this script requires root privilege" >&2
	exit 1
fi

(
	set -x
	mkdir -p /usr/local/lib/systemd/system
	cp system-bridge/vscode-remote.service system-bridge/vscode-remote.socket /usr/local/lib/systemd/system
	cp system-bridge/start-vscode-remote-proxy.sh /usr/local/libexec
	cp system-bridge/code.sh /usr/local/bin/code
	chmod 0777 /usr/local/bin/code

	systemctl daemon-reload
	systemctl enable vscode-remote.socket
	systemctl restart vscode-remote.socket
	systemctl --no-pager status vscode-remote.socket
)

echo "Done."
