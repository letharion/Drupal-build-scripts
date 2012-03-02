This project will at some future point be replaced with drush and provision..

## Install with:

* git submodule add git@github.com:letharion/Drupal-build-scripts.git build
* git submodule init
* git submodule update
* ln -s build/build.sh build.sh
* ln -s build/install.sh install.sh

### Configuration
In your root directory, create a build.conf.sh, which MUST have DOMAIN and TOPDOMAIN defined.

### Hooks
Each hook supports a pre and a post op.

* hook_OP_install
* hook_OP_profile_make
* hook_OP_nodestream_make

### Example build.conf.sh:
```bash
DOMAIN=nodeone
TOPDOMAIN=se

nodeone_pre_install {
  echo "Now installing"
}
```
