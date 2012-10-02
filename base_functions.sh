#!/bin/bash

# Functions at the top, initialization at the bottom.

source build/signals.sh

while getopts ":n" opt; do
  case $opt in
    n)
      KEEPNS=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# OSX does not necessarily have seq, so we implement it.
seq() {
  local I=$1;
  while [ $2 != $I ]; do {
    echo -n "$I ";
    I=$(( $I + 1 ))
  }; done;
  echo $2
}

# pushd and popd doesn't have a quite option, so we enforce silence
run_cmd() {
  if pushd "${2}" > /dev/null; then
    if ! eval ${1}; then
      die "Command ${1} failed in directory ${2}!";
    fi
    popd > /dev/null
  else
    die "Wanted to run ${1} in ${2} but ${2} does not exist!";
  fi
}

apply_patch() {
  DEPTH=$(echo ${2}|sed 's/[^/]//g'|wc -m)
  PATCH_DIR="patches/";
  for i in $(seq 1 ${DEPTH}); do
    PATCH_DIR="../${PATCH_DIR}";
  done

  echo "Applying patch ${1} in ${2}"
  run_cmd "git apply ${PATCH_DIR}${1}" "${2}" 
}

invoke() {
  if [ "$(type -t ${DOMAIN}_${1})" = "function" ]; then
    ${DOMAIN}_${1}
  fi
}

run_hooked_cmd() {
  invoke "pre_${1}"
  run_cmd "${2}" "${3}"
  invoke "post_${1}"
}

die() {
  echo "${1}"
  exit 1;
}

ask() {
  local ACCEPT="y"
  if [ "${3}" != "" ]; then
    local ACCEPT="${3}"
  fi

  read -p "${1} (y/N)? "
  if [ "${REPLY}" == "${ACCEPT}" ]; then
    run_cmd "${2}";
  fi
}

relink() {
  run_hooked_cmd "relink" "ln -sfn \"${NEWWEB}\" web";
}

source build/sanity_checks.sh

if [ -z "$DATEFORMAT" ]; then
  DATEFORMAT="%F_%H%M%S";
fi
if [ -z "$WEBDIRECTORY" ]; then
  WEBDIRECTORY="web-";
fi
if [ -z "$NEWWEB" ]; then
  DATE=$(date +${DATEFORMAT})
  NEWWEB="${WEBDIRECTORY}${DATE}";
fi

KEEPNS=false;
NS="nodestream";
NSPROFILE="profiles/nodestream";

FULLDOMAIN="${DOMAIN}.${TOPDOMAIN}";
if [ -n "${SUBDOMAIN}" ]; then
  FULLDOMAIN="${SUBDOMAIN}.${FULLDOMAIN}";
fi

if [ ! $PROFILENAME ]; then
  PROFILENAME=${DOMAIN}
fi


