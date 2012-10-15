Drupal build-script wrapping drush and it's extensions make and provision.
Long term this script may move towards becoming a drush extension itself.

## Install with:
### Add to a new repository.

* git submodule add git@github.com:letharion/Drupal-build-scripts.git build
* ln -s build/build.sh build.sh
* ln -s build/install.sh install.sh

### Cloning a project that uses this.

* git submodule update --init

## Configuration
In your root directory, create a build.conf, which MUST have DOMAIN and TOPDOMAIN defined.

## Hooks
Each hook supports a pre and a post op.

* hook_OP_install
* hook_OP_profile_make
* hook_OP_nodestream_make

## Example build.conf:
```bash
DOMAIN=nodeone
TOPDOMAIN=se

nodeone_post_nodestream_make() {
  apply_patch "1463002-1-ctools--avoid_casting_notice_in_pm.patch" "web/profiles/nodestream/modules/ctools"
}

nodeone_post_install() {
  run_cmd "drush cc all" "web/sites/default"
}
```

## Variables:
Variables that get default values from the script unless set otherwise in build.conf, and their meaning.

**DATEFORMAT:** The date formating passed to the `date` command. Only used if the DATE variable gets its default value. Defaults to "%F_%H%M%S".

**DATE:** The timestamp added to the end of the web-directory name. Used to distingush builds from eachother. Defaults to $(date +${DATEFORMAT}).

**WEBDIRECTORY:** Prefix of the name of the directory where the site is built. Defaults to "web-".

**NEWWEB:** Full name of the new build-directory. Defaults to "${WEBDIRECTORY}${DATE}".

**FULLDOMAIN:** Full domain the site runs on. Defaults to ${DOMAIN}.${TOPDOMAIN}.

**PROFILENAME:** Name of the profile. Defaults to ${DOMAIN}.

**PLATFORM_ROOT:** Absolute system path where provision will build the platform. Defaults to "$(pwd)/${NEWWEB}"

**PLATFORM_ALIAS:** Name the platform will be given by provision. Defaults to "platform_${DOMAIN}".

**MAKEFILE:** Relative location and name of the make-file for provision to build. Defaults to "${PROFILENAME}.make"
