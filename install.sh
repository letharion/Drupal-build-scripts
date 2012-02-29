#!/bin/bash

source build/base_functions.sh

read -p "Do a drush site-install (y/n)? "
if [ "$REPLY" != "y" ]; then
  exit 0
fi

invoke "pre_install"
run_cmd "drush @${DOMAIN}-loc site-install ${DOMAIN} --sites-subdir='${DOMAIN}.${TOPDOMAIN}' --site-name='${DOMAIN}.${TOPDOMAIN}'" "web/sites/${DOMAIN}.${TOPDOMAIN}"
run_cmd "drush @${DOMAIN}-loc cc all" "web/sites/${DOMAIN}.${TOPDOMAIN}"
invoke "post_install"

