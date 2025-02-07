#!/usr/bin/env bash
###############################################################################
# File    : aahBuildServer.sh
# Info    : Octopus Deploy.sh script for aahBuildServer package
# Date    : 2018-01-23
# Author  : Elli Wang
# Version : 2018102501
# Note    :
#   2018-10-25	Elli	Remove deploying aah.war, which moved to aahGUI
#   2018-10-02	Elli	GA 1.8.0. Add ojdbc7-12.1.0.2.jar to aah.war
#   2018-07-11	Elli	Remove context.xml in aah.war
#   2018-06-21	Elli	GA 1.6.0
#   2018-06-21	Elli	Add UploadTemplate.csv
#   2018-04-13	Elli	GA 1.5.0
#   2018-03-23	Elli	GA 1.4.0
#   2018-03-09	Elli	GA 1.3.0
#   2018-02-02	Elli	GA 1.2.2
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
RC=0
AAH_PROJECT="${1}"
AAH_PROJECT_FOLDER="${2}"

# Aptitude variables
APT_BASE="/opt/aptitude"
SRC_BASE="$PWD/appSvr/src/main/buildAptitude"
AAH_CUSTOM_BASE="$PWD/aah/aahCustom"
APT_HOST=$(hostname)
APT_BUS_NAME="APT_BUS"
APT_SRV_PORT=2500
APT_BUS_PORT=2503

# Command variables
APTCMD_OPTS="-host $APT_HOST -port $APT_SRV_PORT -os_auth yes"
APTCMD="$APT_BASE/bin/aptcmd"
APTSRV="$APT_BASE/bin/aptsrv"
AWK="/usr/bin/awk"
FIND="/usr/bin/find"
INSTALL="/usr/bin/install"
MV="/usr/bin/mv"
STARTAPT="/aah/scripts/startApt.sh"
STARTPROJECTS="/aah/scripts/startProjects.sh"
STOPAPT="/aah/scripts/stopApt.sh"
TAR="/usr/bin/tar"

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	exit 1
}

# Run a command
RUN () {
	if [[ $IS_DEBUG != 1 ]]; then
		"$@"
	else
		echo "Debug: $@"
	fi
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

[[ -n $AAH_PROJECT ]] \
	|| ERR_EXIT "AAH_PROJECT variable is empty!"
printf "Octopus BrdFileName: $AAH_PROJECT.brd ...\n"
[[ -n $AAH_PROJECT_FOLDER ]] \
	|| ERR_EXIT "AAH_PROJECT_FOLDER variable is empty!"
printf "Octopus DeployFolder: $AAH_PROJECT_FOLDER ...\n"

# Stop Aptitude Project ------------------------------------------------------
#printf "Stopping project $AAH_PROJECT_FOLDER/$AAH_PROJECT\n"
#RUN $APTCMD -stop -project "$AAH_PROJECT_FOLDER/$AAH_PROJECT" $APTCMD_OPTS 

# Deploy Aptitude project ----------------------------------------------------
printf "* Deploy Aptitude projects ...\n"
current_dir=$(pwd)

printf "* Deploy project: $current_dir/$AAH_PROJECT.brd.config to folder: $AAH_PROJECT_FOLDER ...\n"
RUN $APTCMD -deploy -project_file_path $current_dir/$AAH_PROJECT.brd \
	-config_file_path $current_dir/$AAH_PROJECT.brd.config -redeployment_type full \
	-folder $AAH_PROJECT_FOLDER $APTCMD_OPTS \
	|| ERR_EXIT "Cannot deploy project $AAH_PROJECT_FOLDER: $current_dir/$AAH_PROJECT.brd!"

# Stop Aptitude Project ------------------------------------------------------
printf "Starting project $AAH_PROJECT_FOLDER/$AAH_PROJECT\n"
RUN $APTCMD -start -project "$AAH_PROJECT_FOLDER/$AAH_PROJECT" $APTCMD_OPTS 

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC