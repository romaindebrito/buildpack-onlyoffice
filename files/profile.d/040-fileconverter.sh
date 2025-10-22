#!/usr/bin/env bash

start_fileconverter() {
	echo "Starting OnlyOffice FileConverter"
	/app/server/FileConverter/converter &
}

ensure_fileconverter() {
	while true; do
		sleep 30s
		if ! pgrep -f '/app/server/FileConverter/converter' >/dev/null; then
			echo "FileConverter does not seem to be running. Respawning."
			start_fileconverter
		fi
	done &
}

# Only start OnlyOffice fileconverter if the conditions are OK
# `_OO_START` is computed in 020-onlyoffice.sh
if [ -z "${ONLYOFFICE_FILECONVERTER_DISABLE_DAEMON}" ] \
		&& [ "${_OO_START}" -eq 0 ]
then
	ensure_fileconverter
fi
