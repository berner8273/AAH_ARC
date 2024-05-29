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

#printf "setup security-external-api\n"

#mkdir -p ${SecurityApiDirectory} || ERR_EXIT "ERROR creating security api directory"

#unzip -o ./security-external-api/zip/security-api-service.zip -d ${SecurityApiDirectory} || ERR_EXIT "ERROR unzipping security api\n"
#cp ./drivers/*.jar ${SecurityApiDirectory}/drivers || ERR_EXIT "ERROR copy driver Jar files\n"
#cp ./application.properties ${SecurityApiDirectory}/config || ERR_EXIT "ERROR copying application.properties file\n"

#printf "***** running security api ****** **\n"
#chmod +x ${SecurityApiDirectory}/bin/security-external.sh
#nohup ${SecurityApiDirectory}/bin/security-external.sh service
#printf "***** completed security api ****** **\n"

printf "Running installer for installWebApps\n"
cp ./ApplicationResources.properties ./aah-web-setup/assets || ERR_EXIT "ERROR coping application resources property file\n"
cp ./AAH.web.legacy.prepare.acc.yaml ./aah-web-setup/.acc  || ERR_EXIT "ERROR coping acc legacy YAML file\n"
./run.sh unattended -rf ${AahInstallerYaml} -op installWebApps || ERR_EXIT "ERROR running aah insaller for web apps\n"
printf "completed installer for installWebApps\n"


if [ -f $RemoveInstallYaml ]; then
    printf "removing yaml installation file\n"
    rm ${AahInstallerYaml} || "Error removing yaml file\n"
fi

printf "*** $PROGRAM ends ... $(date +'%F %T')\n"