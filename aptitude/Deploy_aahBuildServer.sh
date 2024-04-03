#!/usr/bin/env bash
###############################################################################
# File    : aahBuildServer.sh
# Info    : Octopus Deploy.sh script for aahBuildServer package
# Date    : 2018-01-23
# Author  : Elli Wang
# Version : 2024040201
# Note    :
#   2024-04-02 	Elli	GA 21.4.1.1741
#   2024-04-02	Elli	Remove deploying aptsrv
#   2024-04-01	Elli	Remove copying srv_exp.xml
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

# Aptitude variables
APT_BASE="/opt/aptitude"
APT_HOST=localhost
APT_BUS_NAME="APT_BUS"
APT_SRV_PORT=2500
APT_BUS_PORT=2503

# Command variables
APTCMD_OPTS="-host $APT_HOST -port $APT_SRV_PORT -login admin"
APTCMD="$APT_BASE/bin/aptcmd"
APTSRV="$APT_BASE/bin/aptsrv"
FIND="/usr/bin/find"
INSTALL="/usr/bin/install"
MV="/usr/bin/mv"
PERL="/usr/bin/perl"
STARTAPT="/aah/scripts/startApt.sh"
STARTPROJECTS="/aah/scripts/startProjects.sh"
STOPAPT="/aah/scripts/stopApt.sh"
TAR="/usr/bin/tar"

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	RC=1
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

# Check if debug mode
if [[ $(get_octopusvariable "AAH.Octopus.RunScripts"|tr '[A-Z]' '[a-z]') \
		= "false" ]]; then
	printf "** Run scripts in debug mode!!!\n"
	IS_DEBUG=1
fi

# Delete Aptitude server ------------------------------------------------------
printf "* Delete Aptitude server ...\n"

# Stop Aptitude server
printf "* Stop Aptitude server ...\n"
RUN $STOPAPT || ERR_EXIT "Cannot stop Aptitude server!"

# Check Aptitude processes
printf "* Check Aptitude processes ...\n"
if [[ $IS_DEBUG = 0 ]]; then
	for s in 5 10 15 30 30 30; do
		PROCESS=$(pgrep -l 'apt(srv|eng|bus|exe)')
		if [[ -n $PROCESS ]]; then
			printf "Sleep $s seconds ...\n"
			sleep $s
		else
			break
		fi
	done
	[[ -z $PROCESS ]] \
		|| ERR_EXIT "Cannot kill Aptitude processes!\n$PROCESS"
fi

# Check directory
[[ -w $APT_BASE ]] || ERR_EXIT "Cannot write to $APT_BASE!"

# Remove server contents
printf "* Remove $APT_BASE/* ...\n"
RUN $FIND $APT_BASE/ -xdev -mindepth 1 -delete \
	|| ERR_EXIT "Cannot remove $APT_BASE/*!"

# Build Aptitude server -------------------------------------------------------
printf "* Build Aptitude server ...\n"

# Untar Aptitude software
printf "* Untar Aptitude software ...\n"
TARBALL="/aah/src/aptitude-current.tgz"
RUN $TAR --strip-components=1 -C $APT_BASE -zxf $TARBALL \
	|| ERR_EXIT "Cannot untar $TARBALL!"

# Copy ini files
printf "* Copy ini files ...\n"
/usr/bin/ls ./ini/* | \
	while read file; do
		RUN $INSTALL -m 640 -pv $file $APT_BASE/ini/ \
			|| ERR_EXIT "Cannot copy $file!"
	done

# Copy license file
LICENSE=/aah/src/aptitude.apl
printf "* Copy license file ...\n"
[[ -n $LICENSE ]] \
	|| ERR_EXIT "Octopus variable 'LicenseFile' is not defined!"
RUN $INSTALL -m 640 -pv $LICENSE $APT_BASE/ini/ \
	|| ERR_EXIT "Cannot copy license file - $LICENSE!"

# Start Aptitude server
printf "* Start Aptitude server ...\n"
RUN $STARTAPT || ERR_EXIT "Cannot start Aptitude server!"

# Remove bus server
printf "* Remove aptbus server ...\n"
RUN $APTCMD -remove_bus_server -bus_server_name bus $APTCMD_OPTS \
	|| ERR_EXIT "Cannot remove bus server!"

# Add bus server
printf "* Add aptbus server ...\n"
RUN $APTCMD -add_bus_server -bus_server_name $APT_BUS_NAME \
	-bus_server_host $APT_HOST -bus_server_port $APT_BUS_PORT \
	-bus_server_description $APT_BUS_NAME $APTCMD_OPTS \
	|| ERR_EXIT "Cannot add bus server!"

# Load configuration definitions
template="$PWD/config_definitions/template.config_def"
export user
export PKCS7
for user in FDR GUI RDR SLR STN; do
	printf "* Load configuration definition: $user ...\n"
	config=$PWD/config_definitions/${user}.config

	# Get user's password
	printf "Get user's password from Octopus variable\n"
	TEXT=$(get_octopusvariable "${user,,}Password")
	[[ -n $TEXT ]] \
		|| ERR_EXIT "Octopus variable ${user,,}Password is not defined!"
		
	# Encoding user's password
	printf "Perform PKCS7 encoding\n"
	PKCS7=$(RUN $APTCMD -pkcs7_encode -text $TEXT -$APTCMD_OPTS)
	[[ -n $PKCS7 ]] || ERR_EXIT "Cannot perform PKCS7 encoding!"
		
	# Update cofiguration file
	RUN $PERL -pe 's/\@pkcs7Envelope\@/$ENV{PKCS7}/;s/\@userName\@/$ENV{user}/' \
		$template > $config
		
	# Run aptcmd
	RUN $APTCMD -load_config_definition -config_file_path $config \
		-overwrite true $APTCMD_OPTS \
		|| ERR_EXIT "Cannot load configuration definition $config!"
done

# Deploy Aptitude execution folders -------------------------------------------
printf "* Deploy Aptitude execution folders ...\n"
for f in trigger core custom; do
	printf "* Add Aptitude execution folder: $f ...\n"
	RUN $APTCMD -add_folder -folder $f $APTCMD_OPTS \
		|| ERR_EXIT "Cannot add Aptitude execution folder $f!"
done

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC