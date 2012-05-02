#!/bin/bash

source build/base_functions.sh

run_cmd "mkdir -p ${NEWWEB}";
run_cmd "mkdir sites; mkdir profiles" "${NEWWEB}";

run_cmd "ln -s ../../${FULLDOMAIN} ." "${NEWWEB}/sites";
run_cmd "ln -s ../../${PROFILENAME}_profile ${PROFILENAME}" "${NEWWEB}/profiles";

run_hooked_cmd "profile_make" "drush -y make --working-copy --no-gitinfofile profiles/${PROFILENAME}/${PROFILENAME}.make" "${NEWWEB}";

if ${KEEPNS}; then
  run_cmd "cp -r ${OLDWEB}/profiles/${NS} ${NEWWEB}/profiles/${NS}";
else
  # @TODO Should we always use git here?
  run_cmd "git clone http://git.drupal.org/project/nodestream nodestream" "${NEWWEB}/profiles";
  run_cmd "git checkout ${NSVERSION}" "${NEWWEB}/${NSPROFILE}";
  run_hooked_cmd "nodestream_make" "drush -y make --no-core --contrib-destination=. drupal-org.make" "${NEWWEB}/profiles/nodestream";
fi

if [ ${OLDWEB} ]; then
  ask "Do you want to move the web/ symlink from ${OLDWEB} to ${NEWWEB}" "relink";
  ask "Do you want to remove the directory ${OLDWEB} and all its contents" "rm -rf ${OLDWEB}";
else
  relink;
fi

exit 0;
