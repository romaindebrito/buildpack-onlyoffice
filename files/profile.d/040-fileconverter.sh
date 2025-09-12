#!/usr/bin/env bash

start_fileconverter() {
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

ensure_fileconverter
