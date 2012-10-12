#!/bin/bash

source build/base_functions.sh

# Update the platform path to the new one.
# @TODO There should probably be a way to keep old platforms around as well.
run_cmd "drush --debug provision-save @${PLATFORM_ALIAS} --context_type=platform --root=${PLATFORM_ROOT} --makefile=${MAKEFILE}"

run_cmd "drush provision-verify @${PLATFORM_ALIAS}"
run_cmd "drush make ${MAKEFILE} ${PLATFORM_ROOT}"

run_cmd "drush provision-save ${DOMAIN} --uri=${FULLDOMAIN} --platform=@${PLATFORM_ALIAS} --context_type=site --client_name=admin --db_server=@server_master --profile=${DOMAIN}"

run_cmd "ln -s ../../${FULLDOMAIN} ." "${NEWWEB}/sites";

if [ ${OLDWEB} ]; then
  ask "Do you want to move the web/ symlink from ${OLDWEB} to ${NEWWEB}" "relink";
  ask "Do you want to remove the directory ${OLDWEB} and all its contents" "rm -rf ${OLDWEB}";
else
  relink;
fi

exit 0;
