#!/usr/bin/env bash

## Create configuration file overriding defaults:

custom_config_template="${HOME}/config/production.json.erb"

if ! erb "${custom_config_template}" > "${HOME}/config/production.json" \
		2>/dev/null
then
	echo "Unable to generate custom configuration file. Aborting" >&2
	exit 2
fi
