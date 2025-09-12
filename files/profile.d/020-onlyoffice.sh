#!/usr/bin/env bash

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/clamav/lib"
export LD_LIBRARY_PATH

# Whether we should start OnlyOffice services or not (defaults is yes):
OO_START=0

# Get the process type name we're running in:
# We must support "one-off" as a valid process type name, hence using rev:
current_process_type="$( echo "${CONTAINER}" | rev | cut -d'-' -f2- | rev )"

# Create the disabled array by parsing ONLYOFFICE_DOCUMENTSERVER_DISABLE_PROCESS_TYPES
# Defaults to "postdeploy,one-off" when ONLYOFFICE_DOCUMENTSERVER_DISABLE_PROCESS_TYPES is unset.
IFS=', ' read -r -a disabled \
	<<< "${ONLYOFFICE_DOCUMENTSERVER_DISABLE_PROCESS_TYPES:-"postdeploy,one-off"}"

# Check if we are in a process type for which we **don't** want to start OO:
for p in "${disabled[@]}"; do
	if [ "${p}" == "${current_process_type}" ]; then
		OO_START=1
		break
	fi
done

export OO_START
