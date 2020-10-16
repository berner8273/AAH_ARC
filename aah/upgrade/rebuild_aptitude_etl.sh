#!/bin/bash

#Rebuild the aptitude ETL platform and deploy projects to it.
./gradlew -Penv=${1} :appSvr:deleteServer :appSvr:buildServer deployAptitudeExecutionFolders deployAptitudeProjects -PbrdFileSet=all

#Start all projects deployed to the Aptitude ETL platform.
/aah/scripts/startProjects.sh

echo "Aptitude server"

#Prepare the AAH GUI for deployment.
./gradlew -Penv=${1} :aah:aahCore:prepareGUI

echo "AAH GUI prepared"