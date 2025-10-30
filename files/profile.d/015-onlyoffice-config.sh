#!/usr/bin/env bash

## Create configuration file overriding defaults:
#
custom_config_template="${HOME}/config/production.json.erb"

if ! erb "${custom_config_template}" > "${HOME}/config/production.json" \
		2>/dev/null
then
	echo "Unable to generate custom configuration file. Aborting" >&2
	exit 2
fi


## Create cache tag:
#
hash="$( date +'%Y.%m.%d-%H%M' | openssl md5 | awk '{print $2}' )"

# Export cache tag so it can be used by nginx:
OO_DS_CACHE_TAG="${hash}"
export OO_DS_CACHE_TAG

# Generate api.js file:
api_path="${HOME}/web-apps/apps/api/documents/api.js"
cp --force "${api_path}.tpl" "${api_path}"
sed -i "s/{{HASH_POSTFIX}}/${hash}/g" "${api_path}"
rm --force "${api_path}.gz"
