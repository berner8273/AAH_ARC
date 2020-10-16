#!/usr/bin/bash
###############################################################################
# File    : Deploy_aahDBCustomUpgrade.sh
# Info    : Octopus Deploy.sh script for aahDBCustomUpgrade package
# Date    : 2018-01-19
# Author  : Elli Wang
# Version : 2019031101
# Note    :
#   2019-03-11	Elli	GA 1.9.0
#   2018-04-13	Elli	GA 1.5.0
#   2018-03-13	Elli	GA 1.4.0
#   2018-03-09	Elli	GA 1.3.0
#   2018-02-02	Elli	GA 1.2.2
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
IS_DEBUG=0
IS_SQLPLUS_ECHO=off
OPTS_SQLPLUS="-S"
RC=0

# Set Oracle environment
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/client
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$ORACLE_HOME/bin
export TNS_ADMIN=$ORACLE_HOME/network/admin

# Command variables
STOPAPT="/aah/scripts/stopApt.sh"
SQLPLUS="sqlplus"

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
		printf "Debug: $@\n"
	fi
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

# Check if debug mode
if [[ $(get_octopusvariable "AAH.Octopus.RunScripts" \
		| tr '[:upper:]' '[:lower:]') = "false" ]]; then
	printf "** Run scripts in debug mode!!!\n"
	IS_DEBUG=1
fi

# Check if sqlplus echo flag
if [[ $(get_octopusvariable "AAH.Octopus.SQLPlusEcho" \
		| tr '[:upper:]' '[:lower:]') = "on" ]]; then
	IS_SQLPLUS_ECHO=on
	OPTS_SQLPLUS=""
	printf "** Run sqlplus echo $IS_SQLPLUS_ECHO!!!\n"
fi

# Get Oracle host name
printf "* Get Oracle host name ...\n"
oraHost=$(get_octopusvariable "aptitudeDatabaseHost")
[[ -n $oraHost ]] || ERR_EXIT "aptitudeDatabaseHost variable is empty!"

# Get Oracle service name
printf "* Get Oracle service name ...\n"
oraServiceName=$(get_octopusvariable "aptitudeDatabaseServiceName")
[[ -n $oraServiceName ]] \
	|| ERR_EXIT "aptitudeDatabaseServiceName variable is empty!"

# Get user information
for u in fdr gui rdr sla slr stn sys unittest; do
	printf "* Get $u information ...\n"
	v_user="${u}Username"
	v_pwd="${u}Password"
	declare $v_user=$(get_octopusvariable "$v_user")
	[[ -n ${!v_user} ]] || ERR_EXIT "$v_user variable is empty!"
	declare $v_pwd=$(get_octopusvariable "$v_pwd")
	[[ -n ${!v_pwd} ]] || ERR_EXIT "$v_pwd variable is empty!"
	v_cs="${u}Logon"
	declare $v_cs="${!v_user}/${!v_pwd}@${oraHost}/${oraServiceName}"
done

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

# change to aah/upgrade directory
UPG_DIR="upgrade"
printf "* Change directory to $UPG_DIR ...\n"
cd $UPG_DIR || ERR_EXIT "Cannot switch to $UPG_DIR!"

# Run SQL upgrade script
LOG="$PWD/upgrade_install.log"
[[ $IS_DEBUG != 1 ]] || LOG="/dev/null"
printf "* Run SQL upgrade script ... $(date +'%F %T')\n"
RUN $SQLPLUS $OPTS_SQLPLUS /nolog <<- EOF! 2>&1 >> $LOG | tee -a $LOG
	whenever oserror exit 2
	whenever sqlerror exit 2
	set echo $IS_SQLPLUS_ECHO
	@install \
	$fdrLogon \
	$guiLogon \
	$rdrLogon \
	$slaLogon \
	$slrLogon \
	$stnLogon \
	$sysLogon \
	$unittestLogon
	exit
EOF!
RC=${PIPESTATUS[0]}

# Create Octopus artifact
printf "* Create artifact - ${LOG##*/} ... $(date +'%F %T')\n"
RUN new_octopusartifact $LOG ${LOG##*/} \
	|| ERR_EXIT "Cannot create an Octoups artifact - $LOG!"

# Check error and warning
[[ $RC = 0 ]] || ERR_EXIT "Fail on database customisations! See ${LOG##*/}"
NO_ERROR=$(grep -ic error $LOG)
[[ $NO_ERROR = 0 ]] \
	|| printf "!!! Error: $NO_ERROR in ${LOG##*/} !!!\n"
NO_WARNING=$(grep -ic warning $LOG)
[[ $NO_WARNING = 0 ]] \
	|| printf "!!! Warning: $NO_WARNING in ${LOG##*/} !!!\n"

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC