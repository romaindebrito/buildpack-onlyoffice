#!/usr/bin/env bash

start_docservice() {
	/app/server/DocService/docservice &
}

ensure_docservice() {
	start_docservice

	while true
	do
		sleep 15s
		pidof "docservice" > /dev/null \
			|| {
				echo "DocService does not seem to be running. Respawning." >&2
				start_docservice
			}
	done &
}

# Only start OnlyOffice docservice if the conditions are OK
# `_OO_START` is computed in 020-onlyoffice.sh
if [ -z "${ONLYOFFICE_DOCUMENTSERVER_DISABLE_DAEMON}" ] \
		&& [ "${_OO_START}" -eq 0 ]
then
	ensure_docservice
fi
