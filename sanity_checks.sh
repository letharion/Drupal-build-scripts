#!/bin/bash

# Rather brittle test for the existance of drush make. Needs an improvement.
NUM_MAKE_LINES=$(drush | grep "^ make" | wc -l);

if [ "$NUM_MAKE_LINES" -lt 1 ]; then
  die "The drush extension make does not exist. Aborting.";
fi

if [ ! -f build.conf ]; then
  die "You need to create a build.conf file. See the README for an example.";
fi
source build.conf;

if [ -e web ] && [ ! -L web ]; then
  die "web/ exists, but is not a symlink. Please remove it, as it will be overwritten."
else
  OLDWEB=`readlink web`;
fi
