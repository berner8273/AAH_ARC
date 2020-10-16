#!/usr/bin/bash
###############################################################################
# File    : PreDeploy_aahDatabasePartial.sh
# Info    : Octopus PreDeploy.sh script for aahDatabasePartial package
# Date    : 2018-04-24
# Author  : Elli Wang
# Version : 2018060801
# Note    :
#   2018-06-08	Elli	GA 1.6.0
#   2018-04-24	Elli	GA 1.5.0
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
WORK_DIR="$PWD"
IS_DEBUG=0
RC=0

# Set Oracle environment
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/client
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$ORACLE_HOME/bin
export TNS_ADMIN=$ORACLE_HOME/network/admin

# Command variables
SQLPLUS="sqlplus"
STOPAPT="/aah/scripts/stopApt.sh"

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

# Stop Aptitude server
if [[ -x $STOPAPT ]]; then
	printf "* Stop Aptitude server ...\n"
	RUN $STOPAPT || ERR_EXIT "Cannot stop Aptitude server!"
else
	printf "* Aptitude control scripts are not installed!\n"
fi

# Check Aptitude processes
printf "* Check Aptitude processes ...\n"
if [[ $IS_DEBUG = 0 ]]; then
	for s in 5 10 15 30; do
		PROCESS=$(pgrep -l 'apt(srv|eng|bus|exe)')
		if [[ -n $PROCESS ]]; then
			printf "Sleep $s seconds ..."
			sleep $s
		else
			break
		fi
	done
	[[ -z $PROCESS ]] || ERR_EXIT "Error: Cannot kill Aptitude processes!"
fi

# Get Database hostname
printf "* Get database hostname ...\n"
dbHost=$(get_octopusvariable "aptitudeDatabaseHost")
[[ -n $dbHost ]] \
	|| ERR_EXIT "aptitudeDatabaseHost variable is empty!"

# Get TNS alias name
printf "* Get TNS alias ...\n"
tnsAlias=$(get_octopusvariable "aptitudeDatabaseServiceName")
[[ -n $tnsAlias ]] \
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
	declare $v_cs="${!v_user}/\"${!v_pwd}\"@$dbHost/$tnsAlias"
done

# Shutdwon Oracle
printf "* Shutdown Oracle ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $sysLogon as sysdba
	shutdown immediate
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot shutdown Oracle database!"

# Start Oracle
printf "* Start Oracle ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $sysLogon as sysdba
	startup
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot startup Oracle database!"

# Undeploy AAH database customisations ----------------------------------------
LOG="$WORK_DIR/db_undeploy.log"
for d in aahRDR aahSubLedger aahGui aahStandardisation aahStepTrigger;
do
	# Change directory to $d
	SCRIPT_DIR="$WORK_DIR/aahCustom/$d/src/main/db"
	printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
		| tee -a $LOG
	RUN cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

	# Run uninstall.sql script
	printf "* Run uninstall.sql ... $(date +'%F %T')\n" | tee -a $LOG
	RUN $SQLPLUS -S /nolog <<- EOF! 2>&1 >> $LOG | tee -a $LOG
		whenever oserror exit 2
		whenever sqlerror exit 2
		@uninstall \
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
	[[ ${PIPESTATUS[0]} = 0 ]] || RC=1
done

# Deploy customisations in aahETL
# Change directory to aahETL
SCRIPT_DIR="$WORK_DIR/aahCustom/aahETL/src/main/db"
printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
	| tee -a $LOG
RUN cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run uninstall.sql script
printf "* Run uninstall.sql ... $(date +'%F %T')\n" | tee -a $LOG
RUN $SQLPLUS -S /nolog <<- EOF! 2>&1 >> $LOG | tee -a $LOG
	whenever oserror exit 2
	whenever sqlerror exit 2
	@uninstall $sysLogon
	exit
EOF!
[[ ${PIPESTATUS[0]} = 0 ]] || RC=1

# Create Octopus artifact
printf "* Create artifact - ${LOG##*/} ... $(date +'%F %T')\n"
RUN new_octopusartifact $LOG ${LOG##*/} \
	|| ERR_EXIT "Cannot create an Octoups artifact - $LOG!"

# Check error and warning
[[ $RC = 0 ]] || ERR_EXIT "Fail on database customisations! See ${LOG##*/}"
[[ $(grep -ic error $LOG) = 0 ]] || printf "!!! Error in ${LOG##*/} !!!\n"
[[ $(grep -ic warning $LOG) = 0 ]] || printf "!!! Warning in ${LOG##*/} !!!\n"

# Purge recyclebin
printf "* Purge Recyclebin ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $sysLogon as sysdba
	purge dba_recyclebin;
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot purge recyclebin!"

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC