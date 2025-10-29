#!/usr/bin/env bash

start_docservice() {
	echo "Starting OnlyOffice DocService"
	/app/server/DocService/docservice &
}

ensure_docservice() {
	while true; do
		sleep 30s
		if ! pgrep -f '/app/server/DocService/docservice' >/dev/null; then
			echo "DocService does not seem to be running. Respawning."
			start_docservice
		fi
	done &
}

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

# Only start OnlyOffice services if conditions are OK
# `_OO_START` is computed in 020-onlyoffice.sh

if [ "${_OO_START}" -eq 0 ]; then
    case "${ONLYOFFICE_MODE}" in
        docservice)
            echo "Starting ONLYOFFICE Document Service..."
            ensure_docservice
            ;;
        fileconverter)
            echo "Starting ONLYOFFICE File Converter..."
            ensure_fileconverter
            ;;
        proxy)
            echo "Starting ONLYOFFICE Proxy..."
            ensure_proxy
            ;;
        *)
            echo "[WARNING] Unknown or undefined ONLYOFFICE_MODE: '${ONLYOFFICE_MODE}'"
            echo "Valid values: docservice | fileconverter | proxy"
            ;;
    esac
fi
