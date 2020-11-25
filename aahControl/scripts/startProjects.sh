#!/usr/bin/env bash
# Variables
PATH=/usr/bin
APTCMD=/opt/aptitude/bin/aptcmd
OPTS="-host localhost -port 2500 -os_auth yes"

# Start all projects
for p in $($APTCMD -list_deployed_projects $OPTS|awk '{print $1"/"$2}')
do
    printf "Starting project... $p\n"
    $APTCMD -start -project "$p" $OPTS
    printf "\n"
done

# Exit
exit
