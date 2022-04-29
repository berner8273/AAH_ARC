#!/bin/bash
PROGRAM="${0##*/}"
AahInstallerYaml="AahInstaller.yaml"
SecurityApiDirectory="/aah/security_api"

# Set Oracle environment

# Functions ===================================================================
# Exit with an error
ERR_EXIT () {
	printf "Error: $@\n"
	exit 1
}

# Main ========================================================================
printf "*** $PROGRAM starts ... $(date +'%F %T')\n"

printf "Running installer for setupDatabaseSchemas\n"
./run.sh unattended -rf ${AahInstallerYaml} -op installWebApps

printf "setup security-external-api "

mkdir -p ${SecurityApiDirectory}

unzip ./security-external-api/zip/security-api-service.zip -d ${SecurityApiDirectory}
cp ./drivers/*.jar ${SecurityApiDirectory}/drivers
cp ./application.properties ${SecurityApiDirectory}/config

printf "running security api"
nohup ${AahInstallerYaml}/bin/security-external.sh &


