#!/bin/bash

source build/base_functions.sh

run_cmd "mkdir -p ${NEWWEB}";
run_cmd "mkdir sites; mkdir profiles" "${NEWWEB}";

run_cmd "ln -s ../../${FULLDOMAIN} ." "${NEWWEB}/sites";
run_cmd "ln -s ../../${PROFILENAME}_profile ${PROFILENAME}" "${NEWWEB}/profiles";

run_hooked_cmd "profile_make" "drush -y make --working-copy profiles/${PROFILENAME}/${PROFILENAME}.make" "${NEWWEB}";

if [ ${OLDWEB} ]; then
  ask "Do you want to move the web/ symlink from ${OLDWEB} to ${NEWWEB}" "relink";
  ask "Do you want to remove the directory ${OLDWEB} and all its contents" "rm -rf ${OLDWEB}";
else
  relink;
fi

exit 0;
