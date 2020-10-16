#!/usr/bin/bash
###############################################################################
# File    : Deploy_aahDatabase.sh
# Info    : Octopus Deploy.sh script for aahDatabase package
# Date    : 2018-02-07
# Author  : Elli Wang
# Version : 2019031101
# Note    :
#   2019-03-08	Elli	GA 1.9.0
#   2019-02-25	Elli	GA 1.8.2
#   2018-05-30	Elli	Fix a missing SQL script
#   2018-05-24	Elli	GA 1.6.0
#   2018-04-24	Elli	GA 1.5.0
#   2018-03-16	Elli	GA 1.4.0
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
CHMOD="/usr/bin/chmod"
FIND="/usr/bin/find"
INSTALL="/usr/bin/install"
SQLPLUS="sqlplus"
UNZIP="/usr/bin/unzip"

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

# Extract AAH.zip
AAH_ZIP="$WORK_DIR/aahCore/src/main/aah/AAH.zip"
BUILD_DIR="$WORK_DIR/build"
printf "* Extract $AAH_ZIP to $BUILD_DIR ...\n"
$UNZIP -qou $AAH_ZIP -d $BUILD_DIR \
	|| ERR_EXIT "Cannot extract $AAH_ZIP to $BUILD_DIR!"

# Change file permission
printf "* Change file permission ...\n"
RUN $FIND $BUILD_DIR -name \*.sh -exec $CHMOD u+x {} \; \
	|| ERR_EXIT "Cannot chmod *.sh under $BUILD_DIR!"

# Copy files
printf "* Copy SQL scripts ...\n"
SRC_DIR="$WORK_DIR/aahCore/src/main/resources/installer"
DEST_DIR="$BUILD_DIR/db_oracle/Utils/CONFIGURER"
FILE="$SRC_DIR/SLR_ENTITY_PROC_GROUP_CONFIG_populate.sql"
RUN $INSTALL -m 640 -pv $FILE $DEST_DIR/ \
	|| ERR_EXIT "Cannot copy $FILE!"
FILE="$SRC_DIR/SLR_ENTITY_PROC_GROUP_populate.sql"
RUN $INSTALL -m 640 -pv $FILE $DEST_DIR/ \
	|| ERR_EXIT "Cannot copy $FILE!"
FILE="$SRC_DIR/SLR_INSTALL_CONFIG_populate.sql"
RUN $INSTALL -m 640 -pv $FILE $DEST_DIR/ \
	|| ERR_EXIT "Cannot copy $FILE!"

# Copy license file
printf "* Copy license file ...\n"
FILE="$WORK_DIR/aahCore/src/main/resources/licences/aahLicence.lic"
RUN $INSTALL -m 640 -pv $FILE $BUILD_DIR/licence/ \
	|| ERR_EXIT "Cannot copy $FILE!"

# Copy jar files
# Note: These jar files were removed from 1.8 gui.jar
printf "* Copy jar files for licenceToolOracle.sh ...\n"
FILE="$WORK_DIR/aahCore/src/main/resources/licences/ojdbc7.jar"
RUN $INSTALL -m 640 -pv $FILE $BUILD_DIR/licence/ \
	|| ERR_EXIT "Cannot copy $FILE!"
FILE="$WORK_DIR/aahCore/src/main/resources/licences/oraclepki.jar"
RUN $INSTALL -m 640 -pv $FILE $BUILD_DIR/licence/ \
	|| ERR_EXIT "Cannot copy $FILE!"
FILE="$WORK_DIR/aahCore/src/main/resources/licences/osdt_cert.jar"
RUN $INSTALL -m 640 -pv $FILE $BUILD_DIR/licence/ \
	|| ERR_EXIT "Cannot copy $FILE!"
FILE="$WORK_DIR/aahCore/src/main/resources/licences/osdt_core.jar"
RUN $INSTALL -m 640 -pv $FILE $BUILD_DIR/licence/ \
	|| ERR_EXIT "Cannot copy $FILE!"

# Deploy database schema ------------------------------------------------------
# Change directory to DatabaseInit
SCRIPT_DIR="$BUILD_DIR/db_oracle/DatabaseInit"
printf "* Change directory to $SCRIPT_DIR ...\n"
cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run create database users script
SCRIPT="$SCRIPT_DIR/create_database.sh"
printf "* Run create database users script - $SCRIPT ... $(date +'%F %T')\n"
export AAH_LOG_FILE_NAME="$SCRIPT.log"
RUN "$SCRIPT" \
	"$sysUsername" "$sysPassword" \
	"$fdrPassword" \
	"$guiPassword" \
	"$stnPassword" \
	"$rdrPassword" \
	"$slrPassword" \
	"$slaPassword" \
	"$tnsAlias" \
	"/oradata/$tnsAlias/datafile" \
	"/oradata/$tnsAlias/datafile" \
	'FDR_DATA' 'STN_DATA' 'RDR_DATA' 'SLR_DATA' 'SLA_DATA' \
	'FDR_DATA_FILE' 'STN_DATA_FILE' 'RDR_DATA_FILE' \
	'SLR_DATA_FILE' 'SLA_DATA_FILE' \
	'512M' '256M' 'ON' '5M' 'UNLIMITED' 'DEFAULT' 'DOUBLE_TBLSP' \
	'FDR_DATA_IDX' 'STN_DATA_IDX' 'RDR_DATA_IDX' \
	'SLR_DATA_IDX' 'SLA_DATA_IDX' \
	'FDR_DATA_IDX_FILE' 'STN_DATA_IDX_FILE' 'RDR_DATA_IDX_FILE' \
	'SLR_DATA_IDX_FILE' 'SLA_DATA_IDX_FILE' \
	|| ERR_EXIT "$SCRIPT fails! See $AAH_LOG_FILE_NAME!"

# Deploy database objects -----------------------------------------------------
# Change directory to DatabaseInstaller
SCRIPT_DIR="$BUILD_DIR/db_oracle/DatabaseInstaller"
printf "* Change directory to $SCRIPT_DIR ...\n"
cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run create database objects script
SCRIPT="$SCRIPT_DIR/create_update_db.sh"
printf "* Run create database objects script - $SCRIPT ... $(date +'%F %T')\n"
#export AAH_LOG_FILE_NAME="$SCRIPT.log" # Full path log will fail
export AAH_LOG_FILE_NAME="create_update_db.sh.log"
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
	|| ERR_EXIT "$SCRIPT fails! See $AAH_LOG_FILE_NAME!"

# Deploy Core AAH license -----------------------------------------------------
# Change directory to $BUILD_DIR
printf "* Change directory to $BUILD_DIR ...\n"
cd $BUILD_DIR || ERR_EXIT "Cannot change directory to $BUILD_DIR!"

# unpack necessary jar files from GUI.war
printf "* Unpack necessary jar files from GUI.war ... $(date +'%F %T')\n"
RUN $UNZIP -jo "./gui_application/Oracle/GUI.war" \
	WEB-INF/lib/GUI.jar \
	WEB-INF/lib/commons-codec-1.3.jar \
	WEB-INF/lib/tomcat-jdbc-7.0.52.jar \
	WEB-INF/lib/tomcat-juli-7.0.52.jar \
	WEB-INF/lib/xstream-1.4.2.jar \
	-d ./licence || ERR_EXIT "Cannot upack jar files!"

# Change directory to $LICENCE_DIR
LICENCE_DIR="$BUILD_DIR/licence"
printf "* Change directory to $LICENCE_DIR ...\n"
cd $LICENCE_DIR || ERR_EXIT "Cannot change directory to $LICENCE_DIR!"

# Load Core AAH licence
printf "* Load licence file ... $(date +'%F %T')\n"
RUN ./licenceToolOracle.sh \
	aahLicence.lic \
	O \
	$dbHost:1521 \
	$tnsAlias \
	$fdrUsername\
	$fdrPassword \
	|| ERR_EXIT "Cannot load Core AAH license file!"

# Deploy Core AAH parallel manager --------------------------------------------
# Change directory to DatabaseInstaller
SCRIPT_DIR="$BUILD_DIR/db_oracle/DatabaseTools/parallel_manager"
printf "* Change directory to $SCRIPT_DIR ...\n"
cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

# Run create parallel manager script
SCRIPT="$SCRIPT_DIR/create_parallel_manager.sh"
LOG="$SCRIPT.log"
#[[ $IS_DEBUG != 1 ]] || LOG="/dev/null"
printf "* Run create parallel manager script - $SCRIPT ... $(date +'%F %T')\n"
RUN "$SCRIPT" $fdrUsername $fdrPassword $tnsAlias 2>&1 > $LOG | tee -a $LOG
RC=${PIPESTATUS[0]}

# Create Octopus artifact
printf "* Create artifact - ${LOG##*/} ... $(date +'%F %T')\n"
RUN new_octopusartifact $LOG ${LOG##*/} \
	|| ERR_EXIT "Cannot create an Octoups artifact - $LOG!"

# Check error and warning
[[ $RC = 0 ]] || ERR_EXIT "Cannot deploy parallel manager! See ${LOG##*/}"
[[ $(grep -ic error $LOG) = 0 ]] || printf "!!! Error in ${LOG##*/} !!!\n"
[[ $(grep -ic warning $LOG) = 0 ]] || printf "!!! Warning in ${LOG##*/} !!!\n"

# Deploy AAH database customisations ------------------------------------------
LOG="$WORK_DIR/db_customisation.log"
#[[ $IS_DEBUG != 1 ]] || LOG="/dev/null"
for d in aahStepTrigger aahStandardisation aahGui aahSubLedger aahRDR;
do
	# Change directory to $d
	SCRIPT_DIR="$WORK_DIR/aahCustom/$d/src/main/db"
	printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
		| tee -a $LOG
	cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

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
	if [[ ${PIPESTATUS[0]} != 0 ]]; then
		RC=1
		printf "!!! Error on $SCRIPT_DIR/install.sql !!!\n" | tee -a $LOG
	fi
done

# Deploy customisations in aahETL
# Change directory to aahETL
SCRIPT_DIR="$WORK_DIR/aahCustom/aahETL/src/main/db"
printf "* Change directory to $SCRIPT_DIR ... $(date +'%F %T')\n" \
	| tee -a $LOG
cd $SCRIPT_DIR || ERR_EXIT "Cannot change directory to $SCRIPT_DIR!"

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
if [[ ${PIPESTATUS[0]} != 0 ]]; then
	RC=1
	printf "!!! Error on $SCRIPT_DIR/install.sql !!!\n" | tee -a $LOG
fi

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