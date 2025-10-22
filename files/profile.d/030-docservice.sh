#!/usr/bin/env bash

start_docservice() {
	echo "Starting OnlyOffice DocService"
	/app/server/DocService/docservice &
}

ensure_docservice() {
	while true; do
		if ! pgrep -f '/app/server/DocService/docservice' >/dev/null; then
			echo "DocService does not seem to be running. Respawning."
			start_docservice
		fi

		sleep 15s
	done &
}

# Only start OnlyOffice docservice if the conditions are OK
# `_OO_START` is computed in 020-onlyoffice.sh
if [ -z "${ONLYOFFICE_DOCUMENTSERVER_DISABLE_DAEMON}" ] \
		&& [ "${_OO_START}" -eq 0 ]
then
	ensure_docservice
fi
