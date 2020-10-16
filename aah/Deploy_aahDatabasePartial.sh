#!/usr/bin/bash
###############################################################################
# File    : Deploy_aahDatabasePartial.sh
# Info    : Octopus Deploy.sh script for aahDatabasePartial package
# Date    : 2018-04-24
# Author  : Elli Wang
# Version : 2019031101
# Note    :
#   2019-03-11	Elli	GA 1.9.0
#   2018-05-24	Elli	GA 1.6.0
#   2018-04-24	Elli	GA 1.5.0
###############################################################################
# Variables
PATH="/usr/bin"
PROGRAM="${0##*/}"
WORK_DIR="$PWD"
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
SQLPLUS="sqlplus"

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $(date +'%F %T')\n" 
	printf "$@\n"
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
for u in fdr gui rdr sla slr stn sys unittest aahPS aahRead aahReport aahSSIS; do
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

# Deploy AAH database customisations ------------------------------------------
LOG="$WORK_DIR/db_customisation.log"
[[ $IS_DEBUG != 1 ]] || LOG="/dev/null"
for d in aahStepTrigger aahStandardisation aahGui aahSubLedger aahRDR;
do
	# Change directory to $d
	SCRIPT_DIR="$WORK_DIR/aahCustom/$d/src/main/db"
	printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
		| tee -a $LOG
	RUN cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

	# Run Install.sql script
	printf "* Run install.sql ... $(date +'%F %T')\n" | tee -a $LOG
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
	[[ ${PIPESTATUS[0]} = 0 ]] || RC=1
done

# Deploy customisations in aahETL
# Change directory to aahETL
SCRIPT_DIR="$WORK_DIR/aahCustom/aahETL/src/main/db"
printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
	| tee -a $LOG
RUN cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run Install.sql script
printf "* Run install.sql ... $(date +'%F %T')\n" | tee -a $LOG
RUN $SQLPLUS $OPTS_SQLPLUS /nolog <<- EOF! 2>&1 >> $LOG | tee -a $LOG
	whenever oserror exit 2
	whenever sqlerror exit 2
	set echo $IS_SQLPLUS_ECHO
	@install \
	$sysLogon \
	$aahPSPassword \
	$aahReadPassword \
	$aahReportPassword \
	$aahSSISPassword
	exit
EOF!
[[ ${PIPESTATUS[0]} = 0 ]] || RC=1

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