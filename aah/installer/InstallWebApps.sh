#!/bin/bash
PROGRAM="${0##*/}"
RemoveInstallYaml=$1
AahInstallerYaml="AahInstaller.yaml"
SecurityApiDirectory="/aah/security_api"

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	exit 1
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

printf "Running installer for setupDatabaseSchemas\n"
cp ./ApplicationResources.properties ./aah-web-setup/assets || ERR_EXIT "EROR coping application resources property file"
./run.sh unattended -rf ${AahInstallerYaml} -op installWebApps || ERR_EXIT "ERROR running aah insaller for web apps"

printf "setup security-external-api\n"

mkdir -p ${SecurityApiDirectory} || ERR_EXIT "ERROR creating security api directory"

unzip ./security-external-api/zip/security-api-service.zip -o -d ${SecurityApiDirectory} || ERR_EXIT "ERROR unzipping security api"
cp ./drivers/*.jar ${SecurityApiDirectory}/drivers || ERR_EXIT "ERROR copy driver Jar files"
cp ./application.properties ${SecurityApiDirectory}/config || ERR_EXIT "ERROR copying application.properties file"


printf "***** running security api ******"
nohup ${AahInstallerYaml}/bin/security-external.sh &


if [ -f $RemoveInstallYaml ]; then
    printf "removing yaml installation file\n"
   rm rm ${AahInstallerYaml} || "Error removing yaml file\n"
fi

printf "*** $PROGRAM ends ... $(date +'%F %T')\n"