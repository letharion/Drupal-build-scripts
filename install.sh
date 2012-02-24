#!/bin/bash

source build/base_functions.sh

read -p "Do a drush site-install (y/n)? "
if [ "$REPLY" != "y" ]; then
  exit 0
fi

invoke "pre_install"
run_cmd "drush site-install ${DOMAIN} --sites-subdir='${DOMAIN}.${TOPDOMAIN}' --site-name='${DOMAIN}.${TOPDOMAIN}'" "web/sites/${DOMAIN}.${TOPDOMAIN}"
run_cmd "drush cc all" "web/sites/${DOMAIN}.${TOPDOMAIN}"
invoke "post_install"

