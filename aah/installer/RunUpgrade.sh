#!/bin/bash
PROGRAM="${0##*/}"
OracleConnString=$1
RemoveInstallYaml=$2
AahInstallerYaml="AahInstaller.yaml"

keepfile="/aah/installer/aah-web-setup/resources/GUI.war"
delfiles="/aah/installer/aah-web-setup/resources/*_*.war"
dir="/aah/installer/aah-web-setup/resources/"
zipfile="/aah/src/installer.zip"
now=$(date)

# echo OracleConn: ${OracleConnString}
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
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://#{aptitudeHost}/SECURITY' WHERE APPLICATION_NAME = 'ASEC';
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://#{aptitudeHost}/aah' WHERE APPLICATION_NAME = 'AAH';
        update SECURITY_CORE.APPLICATION set BASE_URL = 'https://#{aptitudeHost}/scheduler-web' WHERE APPLICATION_NAME = 'ASCHED';
        /
        commit;
    "
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

printf "*** DEPLOY INSTALLER.ZIP ***\n"
if [ -f /usr/bin/unzip ]
then
	chmod +rwx /aah/src/installer.zip
	if ! [ -d /aah/installer ]; then mkdir -p /aah/installer; fi
	if [ -f $zipfile ]
	then
		cp $zipfile /aah/installer/installer.zip
		echo "unzipping files ...."
		cd /aah/installer
		unzip -o installer.zip 1>/dev/null 2>/aah/logs/install_unzip_errors.log
		echo "unzipped_upgrade-"${now} >>/aah/logs/upgrade_files.log 
	fi	
else
	echo "cannot unzip file!"
	exit 1
fi

if [ -f $keepfile ]; then rm -f $keepfile; fi

case $HOSTNAME in
	"aptitude.agl.com")
		echo "rename "${dir}P_GUI.war $keepfile
		mv ${dir}P_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudeci.agl.com")
		echo "rename "${dir}C_GUI.war $keepfile
		mv ${dir}C_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudedev.agl.com")
	  echo "rename "${dir}D_GUI.war $keepfile
		mv ${dir}D_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudeqa.agl.com")
		echo "rename "${dir}Q_GUI.war $keepfile
		mv ${dir}Q_GUI.war $keepfile
		rm -f $delfiles
		;;
	"aptitudeuat.agl.com")
		echo "rename "${dir}U_GUI.war $keepfile
		mv ${dir}U_GUI.war $keepfile
		rm -f $delfiles
		;;
		*) echo "unknown server $HOSTNAME"
			exit 1 ;;	
esac
echo "War file update script completed"				


printf "Running installer for setupDatabaseSchemas\n"


chmod +x RunUpgrade.sh
chmod +x run.sh
chmod +x /aah/installer/security-db/security-db/migration.sh
chmod +x /aah/installer/scheduler-db/scheduler-db/migration.sh
chmod +x /aah/installer/security-db/security-cli/security.sh
chmod +x /aah/installer/scheduler-db/scheduler-cli/scheduler.sh
chmod +rwx /aah/installer/aah-database-setup/database/DatabaseInstaller/Compile/compile_objects.sh
chmod +x /aah/installer/aah-database-setup/database/DatabaseInit/create_database.sh
chmod +x /aah/installer/aah-database-setup/database/DatabaseInit/create_schemas.sh
chmod +x /aah/installer/aah-database-setup/database/DatabaseInit/create_tablespaces.sh
chmod +x /aah/installer/aah-database-setup/database/DatabaseInstaller/create_update_db.sh
chmod -R 755 /aah/installer

./run.sh unattended -rf ${AahInstallerYaml} -op migrateDatabaseSchemas || ERR_EXIT "ERROR running installer for migrateDatabaseSchemas\n"

export PATH=/opt/aptitude/libexec:$PATH
export LD_LIBRARY_PATH=/opt/aptitude/lib
export APTITUDE_SERVERS=/opt/aptitude

printf "Run Update Security entries\n"
runUpdateSecurityEntries || ERR_EXIT "ERROR updating security entries\n"

printf "Running installer for configureEngines\n"
./run.sh unattended -rf ${AahInstallerYaml} -op configureEngines || ERR_EXIT "Error Running installer for configureEngines\n"

# only needed when installing new aptitude server
printf "Running installer for configureServers\n"
./run.sh unattended -rf ${AahInstallerYaml} -op configureServers || ERR_EXIT "Error Running installer for configureServers\n"


if [ -f $RemoveInstallYaml ]; then
    printf "removing yaml installation file\n"
    rm ${AahInstallerYaml} || "Error removing yaml file\n"
fi

printf "*** $PROGRAM ends ... $(date +'%F %T')\n"