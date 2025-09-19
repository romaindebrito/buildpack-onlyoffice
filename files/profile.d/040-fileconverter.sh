#!/usr/bin/env bash

start_fileconverter() {
	echo "Starting OnlyOffice FileConverter"
	/app/server/FileConverter/converter &
}

ensure_fileconverter() {
	start_fileconverter

	while true
	do
		sleep 15s
		pidof "converter" > /dev/null \
			|| {
				echo "FileConverter does not seem to be running. Respawning." >&2
				start_fileconverter
			}
	done &
}

# Only start OnlyOffice fileconverter if the conditions are OK
# `_OO_START` is computed in 020-onlyoffice.sh
if [ -z "${ONLYOFFICE_DOCUMENTSERVER_DISABLE_DAEMON}" ] \
		&& [ "${_OO_START}" -eq 0 ]
then
	ensure_fileconverter
fi
