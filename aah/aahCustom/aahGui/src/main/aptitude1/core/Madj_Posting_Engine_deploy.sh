#!/bin/sh

showUsage() {
    printf "Usage: \033[0;33m./Madj_Posting_Engine_deploy.sh\033[0m <\033[0;33mFOLDER\033[0m> <\033[0;33mLOGIN\033[0m> <\033[0;33mPASSWORD\033[0m>\n"
}
if [ -z "$1" ]
then
    printf "Argument \033[0;36m1\033[0m <\033[0;33mFOLDER\033[0m> is not specified\n"
    showUsage
    exit
fi

if [ -z "$2" ]
then
    printf "Argument \033[0;36m2\033[0m <\033[0;33mLOGIN\033[0m> is not specified\n"
    showUsage
    exit
fi

if [ -z "$3" ]
then
    printf "Argument \033[0;36m3\033[0m <\033[0;33mPASSWORD\033[0m> is not specified\n"
    showUsage
    exit
fi

aptcmd -deploy -project_file_path=/n/Transfer/AAH\ Upgrade/AAHRepo/22.4.1-2024/exports/Deployment\ Packages/Madj_Posting_Engine.brd -config_file_path=/n/Transfer/AAH\ Upgrade/AAHRepo/22.4.1-2024/exports/Deployment\ Packages/Madj_Posting_Engine.brd.config  -folder="$1" -deployment_type normal -redeployment_type full -leave_configuration no -start_after_deployment no -host=127.0.0.1 -port 2000 -login="$2" -password="$3"
