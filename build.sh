#!/bin/bash

source build/base_functions.sh

read -p "Do you really want to the wipe and replace web/ (y/n)? "
if [ "$REPLY" != "y" ]; then
  exit 0
fi

run_cmd "rm -rf web";

run_cmd "mkdir -p web/"
run_cmd "mkdir sites; mkdir profiles" "web";

run_cmd "ln -s ../../${FULLDOMAIN} ." "web/sites";
run_cmd "ln -s ../../${DOMAIN}_profile ${DOMAIN}" "web/profiles"

run_cmd "drush -y make --working-copy profiles/${DOMAIN}/${DOMAIN}.make" "web";

invoke "post_build";

run_cmd "git clone --branch 7.x-2.x http://git.drupal.org/project/nodestream nodestream" "web/profiles";
#run_cmd "git clone http://git.drupal.org/project/nodestream nodestream" "web/profiles";
#run_cmd "git checkout 7.x-2.0-alpha7" "web/profiles/nodestream";

run_cmd "drush -y make --no-core --contrib-destination=. drupal-org.make" "web/profiles/nodestream" 

run_cmd "./install.sh"

exit 0
