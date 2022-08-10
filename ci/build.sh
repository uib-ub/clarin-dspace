#!/usr/bin/env bash

export FS=`pwd` &&
rm -rf /tmp/dspace &&
rm -rf $FS/utilities/project_helpers/sources &&
ln -s $FS $FS/utilities/project_helpers/sources
echo "Update settings" &&
cd $FS/utilities/project_helpers &&
sed -i'' 's/tomcat.(TOMCAT_VERSION)/travis/' ./config/variable.makefile.example &&
sed -i'' 's#DIR_LINDAT_COMMON_THEME.*#DIR_LINDAT_COMMON_THEME :=/tmp/dspace/lindat-common#' ./config/variable.makefile.example &&
sed -i'' 's/dspace.install.dir = /dspace.install.dir = \/tmp\/dspace/' ./config/local.conf.dist &&
sed -i'' 's/jdbc:postgresql:\/\/localhost/jdbc:postgresql:\/\/postgres/' ./config/local.conf.dist &&
sed -i'' 's/\(db.password =\)/\1 password/' ./config/local.conf.dist &&
cd $FS/utilities/project_helpers/config &&
cp local.conf.dist ../sources/local.properties &&
cd $FS/utilities/project_helpers/scripts &&
# superuser dspace is created in our_build.yml
echo "initialising databases" &&
make create_databases &&
echo "Installing prerequisites" &&
free -m -t &&
make install_libs &&
free -m -t &&
make mvn_help &&
make new_deploy | grep -v "Download" &&
free -m -t &&
make print_message &&
cd $FS
