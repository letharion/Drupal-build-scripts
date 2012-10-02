
# trap keyboard interrupt (control-c)
trap build_abort SIGINT
# No statics in bash, so use a global.
ABORTED=false;

build_abort() {
  if ${ABORTED}; then
    echo "Hard abort requested.";
    exit 1;
  fi

  popd;
  ABORTED=true;
  echo "Sort abort requested. Cleaning up";
  if [ -d ${NEWWEB} ]; then
    if [ `readlink web` != "${NEWWEB}" ]; then
      run_cmd "rm -rf ${NEWWEB}"
      echo "Removed unfinished build directory ${NEWWEB}";
    fi
  fi

  echo "Aborting";
  exit 1;
}
