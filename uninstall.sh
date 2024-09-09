systemctl disable --now vscode-remote.socket
systemctl stop vscode-remote.service

rm -f \
	/usr/local/lib/systemd/system/vscode-remote.service \
	/usr/local/lib/systemd/system/vscode-remote.socket \
	/usr/local/libexec/start-vscode-remote-proxy.sh \
	/usr/local/bin/code
