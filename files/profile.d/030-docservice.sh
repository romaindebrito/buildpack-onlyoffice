#!/usr/bin/env bash

start_docservice() {
	/app/server/DocServicedocservice &
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

ensure_docservice
