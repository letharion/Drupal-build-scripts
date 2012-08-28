#!/bin/bash

# Rather brittle test for the existance of drush make. Needs an improvement.
NUM_MAKE_LINES=$(drush | grep "^ make" | wc -l);

if [ "$NUM_MAKE_LINES" -lt 1 ]; then
  echo "The drush extension make does not exist. Aborting.";
  exit 1;
fi
