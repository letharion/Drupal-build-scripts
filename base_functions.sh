#!/bin/bash
if [ ! -f build.conf.sh ]; then
  echo "You need to create a build.conf.sh file. See the README for an example.";
  exit 1;
fi
source build.conf.sh;

if [ -e web ] && [ ! -L web ]; then
  die "web/ exists, but is not a symlink. Please remove it, as it will be overwritten."
else
  OLDWEB=`readlink web`;
fi

NEWWEB="web-$(date +%F-%R)";
KEEPNS=false;
NS="nodestream";
NSPROFILE="profiles/nodestream";
FULLDOMAIN="${DOMAIN}.${TOPDOMAIN}";

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
  if pushd "$2" > /dev/null; then
    if ! eval $1; then
      exit 1
    fi
    popd > /dev/null
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
