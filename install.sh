#!/bin/bash

source build/base_functions.sh

if [ ! $ALLYES ]; then
  read -p "Do a drush site-install (y/n)? "
  if [ "$REPLY" != "y" ]; then
    exit 0
  fi
fi

invoke "pre_install"

OPTS="";
if [ $ALLYES ]; then
  OPTS="-y";
fi

run_hooked_cmd "site_install" "drush @${DOMAIN} site-install ${DOMAIN} --sites-subdir='${FULLDOMAIN}' --site-name='${FULLDOMAIN}' ${OPTS}" "web/sites/${FULLDOMAIN}"

run_cmd "drush @${DOMAIN} cc all" "web/sites/${FULLDOMAIN}"
invoke "post_install"

