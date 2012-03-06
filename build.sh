#!/bin/bash

source build/base_functions.sh

if ${KEEPNS}; then
  NS=nodestream;
  PROFILE_DIR=web/profiles/${NS};
  if [ -d ${PROFILE_DIR} ]; then
    if [ -e .${NS} ]; then
      run_cmd "rm -rf ./.${NS}";
    fi
    run_cmd "mv ${PROFILE_DIR} ./.${NS}";
  elif [ -d .${NS} ]; then
    echo "Found previous .${NS} directory, keeping it.";
  else
    KEEPNS=false;
    echo "Couldn't find ${NS} at either ${PROFILE_DIR} or ./.${NS}. Will rebild it."
  fi
fi

run_cmd "mkdir -p ${NEWWEB}"
run_cmd "mkdir sites; mkdir profiles" "${NEWWEB}";

run_cmd "ln -s ../../${FULLDOMAIN} ." "${NEWWEB}/sites";
run_cmd "ln -s ../../${DOMAIN}_profile ${DOMAIN}" "${NEWWEB}/profiles"

run_hooked_cmd "profile_make" "drush -y make --working-copy profiles/${DOMAIN}/${DOMAIN}.make" "${NEWWEB}";

if ${KEEPNS}; then
  run_cmd "mv .${NS} ${NEWWEB}/profiles/"
else
  run_cmd "git clone --branch 7.x-2.x http://git.drupal.org/project/nodestream nodestream" "${NEWWEB}/profiles";
  run_hooked_cmd "nodestream_make" "drush -y make --no-core --contrib-destination=. drupal-org.make" "${NEWWEB}/profiles/nodestream" 

  # We lack support for picking a NS version here
  #run_cmd "git clone http://git.drupal.org/project/nodestream nodestream" "web/profiles";
  #run_cmd "git checkout 7.x-2.0-alpha7" "web/profiles/nodestream";
fi

if [ -L web ]; then
  OLDWEB=`readlink web`;
fi
run_cmd "ln -sfn \"${NEWWEB}\" web";

run_cmd "./install.sh"

read -p "Do you want to wipe ${OLDWEB} (y/n)? "
if [ "$REPLY" == "y" ]; then
  run_cmd "rm -rf ${OLDWEB}";
fi

exit 0
