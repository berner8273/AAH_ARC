#!/usr/bin/bash
###############################################################################
# File    : PreDeploy_aahDatabase.sh
# Info    : Octopus PreDeploy.sh script for aahDatabase package
# Date    : 2018-02-07
# Author  : Elli Wang
# Version : 2018060801
# Note    :
#   2018-06-08	Elli	GA 1.6.0
#   2018-04-13	Elli	GA 1.5.0
#   2018-03-19	Elli	GA 1.4.0
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

# Get connection string
printf "* Get Oracle connection string ...\n"
sysUsername=$(get_octopusvariable "sysUsername")
[[ -n $sysUsername ]] || ERR_EXIT "sysUsername variable is empty!"
sysPassword=$(get_octopusvariable "sysPassword")
[[ -n $sysPassword ]] || ERR_EXIT "sysPassword variable is empty!"
oraHost=$(get_octopusvariable "aptitudeDatabaseHost")
[[ -n $oraHost ]] || ERR_EXIT "oraHost variable is empty!"
oraServiceName=$(get_octopusvariable "aptitudeDatabaseServiceName")
[[ -n $oraServiceName ]] || ERR_EXIT "oraServiceName variable is empty!"
CS=$sysUsername/\"$sysPassword\"@$oraHost/$oraServiceName

# Shutdwon Oracle
printf "* Shutdown Oracle ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $CS as sysdba
	shutdown immediate
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot shutdown Oracle database!"

# Start Oracle in restricted mode
printf "* Start Oracle in restricted mode ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $CS as sysdba
	startup restrict
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot startup Oracle database!"

# Drop tables
printf "* Drop tables ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set feedback off
	set serveroutput on format wrapped
	connect $CS as sysdba
	declare sql_stmt varchar2(200);
	begin
	for i in (select owner, table_name from dba_tables
				where owner in ('FDR', 'GUI', 'RDR', 'SLA', 'SLR', 'STN',
									'APTITUDE', 'UNITTEST')
					or owner like 'AAH\_%' escape '\'
				order by owner)
	loop
		sql_stmt := 'drop table '
				|| i.owner || '.' || i.table_name
				|| ' cascade constraints purge';
		execute immediate sql_stmt;
	end loop;
	end;
	/
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot drop tables!"

# Purge recyclebin
printf "* Purge Recyclebin ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $CS as sysdba
	purge dba_recyclebin;
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot purge recyclebin!"

# Drop other objects
printf "* Drop other objects ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set feedback off
	set serveroutput on format wrapped
	connect $CS as sysdba
	declare sql_stmt varchar2(200);
	begin
	for i in (select owner, object_type, object_name from dba_objects
				where (owner in ('FDR', 'GUI', 'RDR', 'SLA', 'SLR', 'STN',
									'APTITUDE', 'UNITTEST')
						or owner like 'AAH\_%' escape '\')
					and object_type in ('FUNCTION', 'JAVA CLASS',
							'JAVA RESOURCE', 'PACKAGE', 'PROCEDURE',
							'SEQUENCE', 'SYNONYM')
				order by owner, object_type)
	loop
		sql_stmt := 'drop ' || i.object_type || ' '
				|| i.owner || '."' || i.object_name || '"';
		execute immediate sql_stmt;
	end loop;
	end;
	/
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot drop other objects!"

# Drop schemas
printf "* Drop schemas ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set feedback off
	set serveroutput on format wrapped
	connect $CS as sysdba
	declare sql_stmt varchar2(200);
	begin
	for i in (select username from dba_users
				where username in ('FDR', 'GUI', 'RDR', 'SLA', 'SLR', 'STN',
									'UNITTEST')
					or username like 'AAH\_%' escape '\'
				order by username)
	loop
		sql_stmt := 'drop user ' || i.username || ' cascade';
		execute immediate sql_stmt;
	end loop;
	end;
	/
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot drop schemas!"

# Drop tablespaces
printf "* Drop tablespaces ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set feedback off
	set serveroutput on format wrapped
	connect $CS as sysdba
	declare sql_stmt varchar2(200);
	begin
	for i in (select tablespace_name from dba_tablespaces
				where tablespace_name like '___\_DATA' escape '\'
				or tablespace_name like '___\_DATA_IDX' escape '\'
				order by tablespace_name)
	loop
		sql_stmt := 'drop tablespace '
				|| i.tablespace_name
				|| ' including contents and datafiles cascade constraints';
		execute immediate sql_stmt;
	end loop;
	end;
	/
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot drop tablespaces!"

# Purge recyclebin
printf "* Purge Recyclebin ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $CS as sysdba
	purge dba_recyclebin;
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot purge recyclebin!"

# Disable restricted mode
printf "* Disable restricted mode ... $(date +'%F %T')\n"
RUN $SQLPLUS -S /nolog <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	connect $CS as sysdba
	alter system disable restricted session;
	exit
EOF!
[[ $? = 0 ]] || ERR_EXIT "Cannot disable restricted mode!"

# End =========================================================================
printf "*** $PROGRAM ends ... $(date +'%F %T')\n"
exit $RC