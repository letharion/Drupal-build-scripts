#!/bin/bash
source build.conf.sh

FULLDOMAIN="${DOMAIN}.${TOPDOMAIN}"

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

  run_cmd "git apply ${PATCH_DIR}${1}" "${2}" 
}

function invoke {
  if [ "$(type -t ${DOMAIN}_${1})" = "function" ]; then
    ${DOMAIN}_${1}
  fi
}
