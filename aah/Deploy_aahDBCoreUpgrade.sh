#!/usr/bin/bash
###############################################################################
# File    : Deploy_aahDBCoreUpgrade.sh
# Info    : Octopus Deploy.sh script for aahDBCoreUpgrade package
# Date    : 2018-01-19
# Author  : Elli Wang
# Version : 2018100101
# Note    :
#   2018-04-13	Elli	GA 1.8.0
#   2018-04-13	Elli	GA 1.5.0
#   2018-03-12	Elli	GA 1.4.0
#   2018-03-09	Elli	GA 1.3.0
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
RC=0

# Set Oracle environment
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/client
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$ORACLE_HOME/bin
export TNS_ADMIN=$ORACLE_HOME/network/admin

# Command variables
CHMOD="/usr/bin/chmod"
FIND="/usr/bin/find"
STOPAPT="/aah/scripts/stopApt.sh"
UNZIP="/usr/bin/unzip"

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

# Check if debug mode
if [[ $(get_octopusvariable "AAH.Octopus.RunScripts"|tr '[A-Z]' '[a-z]') \
		= "false" ]]; then
	printf "** Run scripts in debug mode!!!\n"
	IS_DEBUG=1
fi

# Get user information
for u in fdr gui rdr sla slr stn; do
	printf "* Get $u information ...\n"
	v_user="${u}Username"
	v_pwd="${u}Password"
	declare $v_user=$(get_octopusvariable "$v_user")
	[[ -n ${!v_user} ]] || ERR_EXIT "$v_user variable is empty!"
	declare $v_pwd=$(get_octopusvariable "$v_pwd")
	[[ -n ${!v_pwd} ]] || ERR_EXIT "$v_pwd variable is empty!"
done

# Get TNS alias name
printf "* Get TNS alias ...\n"
tnsAlias=$(get_octopusvariable "aptitudeDatabaseServiceName")
[[ -n $tnsAlias ]] \
	|| ERR_EXIT "aptitudeDatabaseServiceName variable is empty!"

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

# Extract AAH.zip
AAH_ZIP="$PWD/aahCore/src/main/aah/AAH.zip"
BUILD_DIR="$PWD/build"
printf "* Extract $AAH_ZIP to $BUILD_DIR ...\n"
RUN $UNZIP -qou $AAH_ZIP -d $BUILD_DIR \
	|| ERR_EXIT "Cannot extract $AAH_ZIP to $BUILD_DIR!"

# Change file permission
printf "* Change file permission ...\n"
RUN $FIND $BUILD_DIR -name \*.sh -exec $CHMOD u+x {} \; \
	|| ERR_EXIT "Cannot chmod *.sh under $BUILD_DIR!"

# Change directory to $SCRIPT_DIR
SCRIPT_DIR="$BUILD_DIR/db_oracle/DatabaseInstaller"
printf "* Change directory to $SCRIPT_DIR ...\n"
RUN cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run upgrade script
SCRIPT="$SCRIPT_DIR/create_update_db.sh"
export AAH_LOG_FILE_NAME="$SCRIPT.log"
printf "* Run upgrade script ...\n"
RUN "$SCRIPT" \
	"$fdrUsername" "$fdrPassword" \
	"$guiUsername" "$guiPassword" \
	"$stnUsername" "$stnPassword" \
	"$rdrUsername" "$rdrPassword" \
	"$slrUsername" "$slrPassword" \
	"$slaUsername" "$slaPassword" \
	"$tnsAlias" \
	'DOUBLE_TBLSP' \
	'FDR_DATA' 'STN_DATA' 'RDR_DATA' 'SLR_DATA' 'SLA_DATA' \
	'FDR_DATA_IDX' 'STN_DATA_IDX' 'RDR_DATA_IDX' \
	'SLR_DATA_IDX' 'SLA_DATA_IDX' \
	|| RC=1
if [[ $RC != 0 ]]; then
	printf "Error log: $AAH_LOG_FILE_NAME\n"
	cat $AAH_LOG_FILE_NAME
	ERR_EXIT "$SCRIPT fails!"
fi

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC