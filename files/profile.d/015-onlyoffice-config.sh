#!/usr/bin/env bash

## Create configuration file overriding defaults:

custom_config_template="${HOME}/config/production.json.erb"

if ! erb "${custom_config_template}" > "${HOME}/config/production.json" \
		2>/dev/null
then
	echo "Unable to generate custom configuration file. Aborting" >&2
	exit 2
fi


## Fix fonts paths:

font_files=(
	${HOME}/server/FileConverter/bin/AllFonts.js
	${HOME}/server/FileConverter/bin/font_selection.bin
	${HOME}/sdkjs/common/AllFonts.js
)

for f in "${font_files[@]}"; do
	sed -i -E 's/\/build\/[a-z0-9-]{36}/\/app/g' "${f}"
done


## Fix themes paths:


