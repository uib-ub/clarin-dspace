#!/bin/bash
make update_lindat_common &&
make grant_rights &&
#TODO have additional overlays directory with structure identical to dspace-installdir (config, webapps...);
# overlay the final install dir
cp --recursive xxx yyy
#TODO example for lang files (messages, licenses)
echo "DEPLOYMENT (INSTALL + POSTINSTALL) SUCCESSFUL"
