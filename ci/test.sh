#!/usr/bin/env bash

export FS=`pwd` &&
cd $FS/utilities/project_helpers/scripts &&
free -m -t &&
make test_dspace_database &&
free -m -t &&
make test_utilities_database &&
free -m -t &&
cd $FS/ && mvn -Dmaven.test.skip=false -Dtest=cz.cuni.mff.ufal.dspace.**.*Test,cz.cuni.mff.ufal.*Test -DfailIfNoTests=false test | grep -v "Download" &&
free -m -t &&
cd $FS/utilities/project_helpers/scripts &&
free -m -t &&
make tests &&
#make selenium_tests || echo "Tests failed"
cd $FS
