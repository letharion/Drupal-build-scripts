#!/bin/bash
source build.conf.sh

#!/bin/bash -x

keepns=false

while getopts ":n" opt; do
  case $opt in
    n)
      keepns=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

FULLDOMAIN="${DOMAIN}.${TOPDOMAIN}"

# OSX does not necessarily have seq, so we implement it.
function seq {
  local I=$1;
  while [ $2 != $I ]; do {
    echo -n "$I ";
    I=$(( $I + 1 ))
  }; done;
  echo $2
}

#pushd and popd doesn't have a quite option, so we enforce silence
function run_cmd {
  if pushd "$2" > /dev/null; then
    if ! eval $1; then
      exit 1
    fi
    popd > /dev/null
  fi
}

function apply_patch {
  DEPTH=$(echo ${2}|sed 's/[^/]//g'|wc -m)
  PATCH_DIR="patches/";
  for i in $(seq 1 ${DEPTH}); do
    PATCH_DIR="../${PATCH_DIR}";
  done

  echo "Applying patch ${1} in ${2}"
  run_cmd "git apply ${PATCH_DIR}${1}" "${2}" 
}

function invoke {
  if [ "$(type -t ${DOMAIN}_${1})" = "function" ]; then
    ${DOMAIN}_${1}
  fi
}

function run_hooked_cmd {
  invoke "pre_${1}"
  run_cmd "${2}" "${3}"
  invoke "post_${1}"
}
