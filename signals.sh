
# trap keyboard interrupt (control-c)
trap build_abort SIGINT
ABORTED=false;

build_abort() {
  if ${ABORTED}; then
    die "Hard abort requested."
  fi

  popd;
  ABORTED=true;
  echo "Sort abort requested. Cleaning up";
  if [ -d ${NEWWEB} ]; then
    if [ `readlink web` != ${NEWWEB} ]; then
      run_cmd "rm -rf ${NEWWEB}"
      die "Removed unfinished build directory ${NEWWEB}";
    fi
  fi

  die "Aborting";
}
