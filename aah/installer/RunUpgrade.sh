#!/bin/bash
PROGRAM="${0##*/}"
OracleConnString=$1
RemoveInstallYaml=$2
AahInstallerYaml="AahInstaller.yaml"
echo OracleConn: ${OracleConnString}
# Set Oracle environment

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	exit 1
}


function runSqlPLus()
{
    #echo "${1}"
    sqlplus ${OracleConnString} <<- EOF!
	whenever oserror exit 2
	whenever sqlerror exit 2
	set serveroutput on format wrapped
    set feedback off
    ${1}
	exit
EOF!

[[ $? = 0 ]] || ERR_EXIT "${1}"
}

function runUpdateSecurityEntries()
{
    echo "----updating SECURITY_CORE.APPLICATION rows-----"
    runSqlPLus "
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://aptitudeci.agl.com/SECURITY' WHERE APPLICATION_NAME = 'ASEC';
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://aptitudeci.agl.com/aah' WHERE APPLICATION_NAME = 'AAH';
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://aptitudeci.agl.com/scheduler-web' WHERE APPLICATION_NAME = 'ASCHED';
        end;
        /
        commit;
    "
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

printf "Running installer for setupDatabaseSchemas\n"
./run.sh unattended -rf ${AahInstallerYaml} -op setupDatabaseSchemas || ERR_EXIT "ERROR running installer for setupDatabaseSchemas\n"

printf "Run Update Security entries\n"
runUpdateSecurityEntries || ERR_EXIT "ERROR updating security entries\n"

printf "Running installer for configureEngines\n"
./run.sh unattended -rf ${AahInstallerYaml} -op configureEngines || ERR_EXIT "Error Running installer for configureEngines\n"

if [ -f $RemoveInstallYaml ]; then
    printf "removing yaml installation file\n"
   rm rm ${AahInstallerYaml} || "Error removing yaml file\n"
fi

printf "*** $PROGRAM ends ... $(date +'%F %T')\n"