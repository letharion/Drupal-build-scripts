## Important notice.
This version (master), is currently not being maintained much, although
important fixes will be commited as necessary. All the interesting work is
happening in either the 'provision' or 'drush-ext' branches. 'provision' is an
intermediary step towards using aegir's backend provision, and do less work in
shell scripting. 'drush-ext' is closer to the intended form of this project.
Shell script free drush extension that relies on provision to do the heavy
lifting, and moves configuration settings into a provision extension.

## Drupal build scripts

This project helps building a Drupal project that is based on the NodeStream profile.
It will at some future point be replaced with drush and provision.

## Install with:
### Add to a new repository.

* git submodule add git@github.com:letharion/Drupal-build-scripts.git build
* ln -s build/build.sh build.sh
* ln -s build/install.sh install.sh

### Cloning a project that uses this.

* git submodule init
* git submodule update
* ln -s build/build.sh build.sh
* ln -s build/install.sh install.sh

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
