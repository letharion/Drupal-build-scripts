#!/bin/bash

source build/base_functions.sh

if [ ! -f "${HOME}/.drush/${PLATFORM_ALIAS}.alias.drushrc.php" ]; then
  run_cmd "drush --debug provision-save @${PLATFORM_ALIAS} --context_type=platform --root=${PLATFORM_ROOT} --makefile=${MAKEFILE}"
fi

run_cmd "drush provision-verify @${PLATFORM_ALIAS}"
run_cmd "drush make ${MAKEFILE} ${PLATFORM_ROOT}"

run_cmd "ln -s ../../${FULLDOMAIN} ." "${NEWWEB}/sites";

if [ ${OLDWEB} ]; then
  ask "Do you want to move the web/ symlink from ${OLDWEB} to ${NEWWEB}" "relink";
  ask "Do you want to remove the directory ${OLDWEB} and all its contents" "rm -rf ${OLDWEB}";
else
  relink;
fi

exit 0;
